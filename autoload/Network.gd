extends Node

var game_running = false

var active_connections = {} # Cache local peers explicitly to structurally isolate from engine-level mesh teardowns

signal lobby_created(code)
signal joined_lobby()
signal joined_queue()
signal match_found(role)
signal match_cancelled()
#signal player_connected(peer_id)
signal player_disconnected(peer_id)
#signal connection_failed()
signal game_error(msg)
signal game_started() # When the handshake is complete and we are ready

# Signaling Server Configuration
# local development URL:
const LOCAL_SIGNALING_URL = "ws://localhost:8080"
# Replace with your actual GCP Cloud Run URL (e.g. wss://app-name-xxxxxx.a.run.app) after deployment:
const PRODUCTION_SIGNALING_URL = "wss://penalty2d-signaling-730456293701.us-central1.run.app"

var SIGNALING_URL = PRODUCTION_SIGNALING_URL

# WebRTC ICE Servers Configuration (STUN and TURN)
const DEFAULT_ICE_SERVERS = [
	{
		"urls": [
			"stun:stun.l.google.com:19302",
			"stun:stun1.l.google.com:19302"
		]
	}
]
var ice_servers = DEFAULT_ICE_SERVERS

# Lobby Settings (configured by Host)
var match_total_rounds := 3
var round_time_limit := 60
var round_ball_count := 5

# Local Player Identity
var player_name := ""

func _reset_network_state():
	code = ""
	is_host = false
	connected_peer_id = 0
	multiplier_peer = null
	multiplayer.multiplayer_peer = null
	active_connections.clear()
	ice_servers = DEFAULT_ICE_SERVERS
	match_total_rounds = 3
	round_time_limit = 60
	round_ball_count = 5
	print("Network state reset successfully.")

var ws: WebSocketPeer = WebSocketPeer.new()
var code = ""
var is_host = false
var multiplier_peer: WebRTCMultiplayerPeer
var connected_peer_id = 0

# Socket buffer queue for high-latency cellular networks
var _pending_payload: Dictionary = {}

# PvP Authority States
enum PlayerRole { NONE, STRIKER, GOALKEEPER }
var my_role_this_round: PlayerRole = PlayerRole.NONE
var opponent_role_this_round: PlayerRole = PlayerRole.NONE

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS # Keep running even if game is paused
	
	# Initialize default nickname
	player_name = "Player_" + str(randi_range(100, 999))
	
	# Force production signaling server for all builds (including debug exports)
	SIGNALING_URL = PRODUCTION_SIGNALING_URL
	
	# Optional: If you want to use a local server when testing in the Godot Editor, un-comment below:
	# if OS.has_feature("editor"):
	# 	SIGNALING_URL = LOCAL_SIGNALING_URL
		
	print("Multiplayer signaling URL: ", SIGNALING_URL)

func _process(_delta):
	ws.poll()
	var state = ws.get_ready_state()
	
	if state == WebSocketPeer.STATE_OPEN:
		# Immediately flush any buffered network commands the instant connection is verified
		if not _pending_payload.is_empty():
			_send_signaling_message(_pending_payload)
			_pending_payload.clear()
			
		while ws.get_available_packet_count():
			_handle_signaling_data(ws.get_packet().get_string_from_utf8())
	elif state == WebSocketPeer.STATE_CLOSED:
		# If we were active in a lobby or queue, handle the disconnect gracefully
		if code != "" or multiplier_peer != null:
			print("Signaling connection closed unexpectedly.")
			_reset_network_state()
			emit_signal("game_error", "Connection to signaling server lost.")

func connect_to_signaling_server():
	if ws.get_ready_state() == WebSocketPeer.STATE_OPEN:
		return # Already securely connected
		
	ws.close()
	var err = ws.connect_to_url(SIGNALING_URL)
	if err != OK:
		emit_signal("game_error", "Failed to connect to signaling server")
		print("Signaling connection error: ", err)

func create_game():
	is_host = true
	_buffer_or_send({"type": "create_lobby"})

func join_game(lobby_code: String):
	is_host = false
	code = lobby_code
	_buffer_or_send({"type": "join_lobby", "code": lobby_code})

func quick_match():
	_buffer_or_send({"type": "quick_match"})

func cancel_matchmaking():
	if code != "":
		_buffer_or_send({"type": "leave_lobby"})
	else:
		_buffer_or_send({"type": "leave_queue"})
	_reset_network_state()

func accept_match():
	_buffer_or_send({"type": "accept_match"})

func decline_match():
	_buffer_or_send({"type": "decline_match"})
	_reset_network_state()

func _buffer_or_send(data: Dictionary):
	if ws.get_ready_state() == WebSocketPeer.STATE_OPEN:
		_send_signaling_message(data)
	else:
		_pending_payload = data # Buffer it to emit frame-perfectly upon OPEN

func _send_signaling_message(data: Dictionary):
	ws.put_packet(JSON.stringify(data).to_utf8_buffer())

func _handle_signaling_data(json_str: String):
	var data = JSON.parse_string(json_str)
	if not data: return
	
	match data.get("type"):
		"lobby_created":
			code = data.get("code")
			emit_signal("lobby_created", code)
			_initialize_multiplayer_peer()
			
		"queue_joined":
			emit_signal("joined_queue")
			
		"match_found":
			if data.has("role"):
				is_host = (data["role"] == "host")
			emit_signal("match_found", data.get("role", "client"))
			
		"match_cancelled":
			_reset_network_state()
			emit_signal("match_cancelled")
			
		"peer_connected":
			if data.has("role"):
				is_host = (data["role"] == "host")
				
			if data.has("ice_servers") and data["ice_servers"] != null:
				ice_servers = data["ice_servers"]
				print("Received ephemeral ICE servers from signaling.")
				
			if is_host and multiplier_peer == null:
				_initialize_multiplayer_peer()
				
			emit_signal("joined_lobby")
			# Start the handshake negotiation natively
			if is_host:
				_create_offer()
				
		"offer":
			if not is_host:
				_initialize_multiplayer_peer()
				_receive_offer(data.get("sdp"), data.get("type"))
				
		"answer":
			if is_host:
				_receive_answer(data.get("sdp"), data.get("type"))
				
		"candidate":
			_receive_candidate(data.get("mid"), data.get("index"), data.get("sdp"))
			
		"peer_disconnected":
			emit_signal("player_disconnected", 0)
			_reset_network_state()
			
		"error":
			emit_signal("game_error", data.get("message"))

func _initialize_multiplayer_peer():
	multiplier_peer = WebRTCMultiplayerPeer.new()
	# Godot 4: Create the mesh.
	# For 1v1 we typically init the mesh first.
	if is_host:
		multiplier_peer.create_mesh(1) # 1 = Host ID
	else:
		multiplier_peer.create_mesh(2) # 2 = Client ID (can be anything unique)

	multiplayer.multiplayer_peer = multiplier_peer
	
	# Create the WebRTC Peer Connection
	var peer = WebRTCPeerConnection.new()
	peer.initialize({
		"iceServers": ice_servers
	})
	
	# Add this peer to the mesh
	# If Host: We add Peer 2. If Client: We add Peer 1.
	var target_id = 2 if is_host else 1
	active_connections[target_id] = peer
	multiplier_peer.add_peer(peer, target_id)
	
	# Connect signals
	peer.session_description_created.connect(_on_session_description_created.bind(target_id))
	peer.ice_candidate_created.connect(_on_ice_candidate_created)
	
	# Wait for connection
	multiplayer.peer_connected.connect(_on_network_peer_connected)
	multiplayer.peer_disconnected.connect(_on_network_peer_disconnected)

func _create_offer():
	var peer = active_connections[2 if is_host else 1]
	peer.create_offer()

func _receive_offer(sdp: String, type: String):
	var peer = active_connections[1]
	peer.set_remote_description(type, sdp)
	# In Godot explicitly submitting a remote 'offer' gracefully automatically triggers the answer engine
	# directly emitting session_description_created dynamically!

func _receive_answer(sdp: String, type: String):
	var peer = active_connections[2]
	peer.set_remote_description(type, sdp)

func _receive_candidate(mid: String, index: int, sdp: String):
	var peer_id = 2 if is_host else 1
	var peer = active_connections[peer_id]
	peer.add_ice_candidate(mid, index, sdp)

func _on_session_description_created(type: String, sdp: String, target_id: int):
	var peer = active_connections[target_id]
	peer.set_local_description(type, sdp)
	
	# Send to signaling
	if type == "offer":
		_send_signaling_message({"type": "offer", "sdp": sdp})
	else:
		_send_signaling_message({"type": "answer", "sdp": sdp})

func _on_ice_candidate_created(mid: String, index: int, sdp: String):
	_send_signaling_message({"type": "candidate", "mid": mid, "index": index, "sdp": sdp})

func _on_network_peer_connected(id):
	print("Network Peer Connected: ", id)
	connected_peer_id = id
	
	# Round 1 Authorities (Host is Striker, Client is Goalkeeper)
	if is_host:
		my_role_this_round = PlayerRole.STRIKER
		opponent_role_this_round = PlayerRole.GOALKEEPER
	else:
		my_role_this_round = PlayerRole.GOALKEEPER
		opponent_role_this_round = PlayerRole.STRIKER
		
	emit_signal("game_started")

func _on_network_peer_disconnected(id):
	print("Network Peer Disconnected: ", id)
	emit_signal("player_disconnected", id)
