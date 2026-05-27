const WebSocket = require('ws');
const https = require('https');

const port = process.env.PORT || 8080;
const wss = new WebSocket.Server({ port });

// Lobbies: { "CODE": { host: ws, client: ws } }
const lobbies = {};

// Queue for generic quick matchmaking
const quickMatchQueue = [];

function heartbeat() {
    this.isAlive = true;
}

wss.on('connection', (ws) => {
    console.log('Client connected');
    ws.isAlive = true;
    ws.on('pong', heartbeat);

    ws.on('message', (message) => {
        try {
            const data = JSON.parse(message);
            handleMessage(ws, data);
        } catch (e) {
            console.error('Invalid JSON:', message);
        }
    });

    ws.on('close', () => {
        console.log('Client disconnected');
        handleDisconnect(ws);
    });
});

const interval = setInterval(() => {
    wss.clients.forEach((ws) => {
        if (ws.isAlive === false) {
            console.log('Terminating unresponsive client connection');
            return ws.terminate();
        }
        
        ws.isAlive = false;
        ws.ping();
    });
}, 30000);

wss.on('close', () => {
    clearInterval(interval);
});

function getTwilioIceServers(accountSid, authToken) {
    return new Promise((resolve) => {
        if (!accountSid || !authToken) {
            console.log('Twilio credentials not configured. Skipping Twilio ICE servers.');
            return resolve(null);
        }

        const auth = Buffer.from(`${accountSid}:${authToken}`).toString('base64');
        const postData = 'Ttl=3600';

        const options = {
            hostname: 'api.twilio.com',
            port: 443,
            path: `/2010-04-01/Accounts/${accountSid}/Tokens.json`,
            method: 'POST',
            headers: {
                'Authorization': `Basic ${auth}`,
                'Content-Type': 'application/x-www-form-urlencoded',
                'Content-Length': Buffer.byteLength(postData)
            }
        };

        const req = https.request(options, (res) => {
            let body = '';
            res.on('data', (chunk) => body += chunk);
            res.on('end', () => {
                try {
                    const data = JSON.parse(body);
                    if (data.ice_servers) {
                        // Transform Twilio's ice_servers to the standard WebRTC / Godot format
                        // Ensuring 'urls' is always an Array of strings
                        const formatted = data.ice_servers.map(server => {
                            const item = {};
                            const urlVal = server.urls || server.url;
                            if (urlVal) {
                                item.urls = Array.isArray(urlVal) ? urlVal : [urlVal];
                            }
                            if (server.username) item.username = server.username;
                            if (server.credential) item.credential = server.credential;
                            return item;
                        });
                        resolve(formatted);
                    } else {
                        console.error('Twilio returned no ice servers:', data);
                        resolve(null);
                    }
                } catch (e) {
                    console.error('Error parsing Twilio response:', e);
                    resolve(null);
                }
            });
        });

        req.on('error', (err) => {
            console.error('Twilio request error:', err);
            resolve(null);
        });

        req.write(postData);
        req.end();
    });
}

function handleMessage(ws, data) {
    const type = data.type;

    switch (type) {
        case 'create_lobby':
            const code = generateCode();
            lobbies[code] = { host: ws, client: null, hostAccepted: false, clientAccepted: false, finding: false };
            ws.lobbyCode = code;
            ws.isHost = true;
            send(ws, { type: 'lobby_created', code: code });
            console.log(`Lobby created: ${code}`);
            break;

        case 'join_lobby':
            const joinCode = data.code;
            if (lobbies[joinCode] && !lobbies[joinCode].client) {
                lobbies[joinCode].client = ws;
                ws.lobbyCode = joinCode;
                ws.isHost = false;
                lobbies[joinCode].finding = true;
                
                // Notify both of preliminary match!
                send(lobbies[joinCode].host, { type: 'match_found', role: 'host' });
                send(ws, { type: 'match_found', role: 'client' });
                console.log(`Peer joined lobby: ${joinCode}. Pending accept...`);
            } else {
                send(ws, { type: 'error', message: 'Lobby not found or full' });
            }
            break;

        case 'quick_match':
            if (quickMatchQueue.length > 0) {
                // If there's anyone waiting, pair up!
                const hostWS = quickMatchQueue.shift();
                
                const c_code = generateCode();
                lobbies[c_code] = { host: hostWS, client: ws, hostAccepted: true, clientAccepted: true, finding: false };
                
                hostWS.lobbyCode = c_code;
                hostWS.isHost = true;
                
                ws.lobbyCode = c_code;
                ws.isHost = false;
                
                // Fetch and forward Twilio ICE servers dynamically to bypass restrictive NATs
                getTwilioIceServers(process.env.TWILIO_ACCOUNT_SID, process.env.TWILIO_AUTH_TOKEN).then((iceServers) => {
                    send(hostWS, { type: 'peer_connected', role: 'host', ice_servers: iceServers });
                    send(ws, { type: 'peer_connected', role: 'client', ice_servers: iceServers });
                });
                console.log(`Matched randomly logically. Bypassing Accept gate. Joined: ${c_code}.`);
            } else {
                // Buffer socket
                quickMatchQueue.push(ws);
                send(ws, { type: 'queue_joined' });
                console.log('Peer entered quickMatch buffer');
            }
            break;
            
        case 'leave_queue':
            const lqIndex = quickMatchQueue.indexOf(ws);
            if (lqIndex > -1) {
                quickMatchQueue.splice(lqIndex, 1);
                console.log('Peer willingly left buffer.');
            }
            break;
            
        case 'leave_lobby':
            if (ws.isHost && ws.lobbyCode && lobbies[ws.lobbyCode] && !lobbies[ws.lobbyCode].client) {
                delete lobbies[ws.lobbyCode];
                ws.lobbyCode = null;
                console.log('Host closed their lobby manually.');
            }
            break;
            
        case 'accept_match':
            if (ws.lobbyCode && lobbies[ws.lobbyCode]) {
                const l = lobbies[ws.lobbyCode];
                if (ws.isHost) {
                    l.hostAccepted = true;
                } else {
                    l.clientAccepted = true;
                }
                console.log(`Peer accepted match. H:${l.hostAccepted} C:${l.clientAccepted}`);
                
                if (l.hostAccepted && l.clientAccepted) {
                    // Both accepted securely! Fetch and boot up WebRTC!
                    getTwilioIceServers(process.env.TWILIO_ACCOUNT_SID, process.env.TWILIO_AUTH_TOKEN).then((iceServers) => {
                        send(l.host, { type: 'peer_connected', role: 'host', ice_servers: iceServers });
                        send(l.client, { type: 'peer_connected', role: 'client', ice_servers: iceServers });
                    });
                    console.log(`Lobby Fully Validated and Handshook: ${ws.lobbyCode}`);
                }
            }
            break;
            
        case 'decline_match':
            if (ws.lobbyCode && lobbies[ws.lobbyCode]) {
                const l = lobbies[ws.lobbyCode];
                const other = ws.isHost ? l.client : l.host;
                if (other) {
                    send(other, { type: 'match_cancelled' });
                    other.lobbyCode = null;
                }
                delete lobbies[ws.lobbyCode];
                ws.lobbyCode = null;
                console.log(`Match explicitly declined. Lobby destroyed.`);
            }
            break;

        case 'offer':
        case 'answer':
        case 'candidate':
            // Relay WebRTC signaling data to the *other* peer in the lobby
            const lobby = lobbies[ws.lobbyCode];
            if (lobby) {
                const target = ws.isHost ? lobby.client : lobby.host;
                if (target) {
                    send(target, data); // Forward the exact message
                }
            }
            break;
            
        case 'ping':
            send(ws, { type: 'pong' });
            break;
    }
}

function handleDisconnect(ws) {
    // Attempt removal from generic Quick Match queue just in case
    const qIndex = quickMatchQueue.indexOf(ws);
    if (qIndex > -1) {
        quickMatchQueue.splice(qIndex, 1);
        console.log('Peer removed from buffer explicitly');
    }

    if (ws.lobbyCode && lobbies[ws.lobbyCode]) {
        const lobby = lobbies[ws.lobbyCode];
        const other = ws.isHost ? lobby.client : lobby.host;
        
        if (other) {
            send(other, { type: 'peer_disconnected' });
            other.lobbyCode = null; // Reset the other peer
        }
        
        delete lobbies[ws.lobbyCode]; // Destroy lobby
        console.log(`Lobby destroyed: ${ws.lobbyCode}`);
    }
}

function send(ws, data) {
    if (ws && ws.readyState === WebSocket.OPEN) {
        ws.send(JSON.stringify(data));
    }
}

function generateCode() {
    return Math.random().toString(36).substring(2, 6).toUpperCase();
}

console.log(`Signaling server running on port ${port}`);
