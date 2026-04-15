const WebSocket = require('ws');

const wss = new WebSocket.Server({ port: 8080 });

// Lobbies: { "CODE": { host: ws, client: ws } }
const lobbies = {};

wss.on('connection', (ws) => {
    console.log('Client connected');

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

function handleMessage(ws, data) {
    const type = data.type;

    switch (type) {
        case 'create_lobby':
            const code = generateCode();
            lobbies[code] = { host: ws, client: null };
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
                
                // Notify both
                send(lobbies[joinCode].host, { type: 'peer_connected', role: 'host' });
                send(ws, { type: 'peer_connected', role: 'client' });
                console.log(`Peer joined lobby: ${joinCode}`);
            } else {
                send(ws, { type: 'error', message: 'Lobby not found or full' });
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

console.log('Signaling server running on ws://localhost:8080');
