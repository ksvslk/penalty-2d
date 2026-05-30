extends "res://scripts/goalkeeper.gd"

var mp_target_x = 540.0

func init_multiplayer():
	# Reconstruct stripped @onready properties
	home_position = global_position
	flag = get_node_or_null("Flag")
	collision_polygon = get_node_or_null("CollisionPolygon2D")

func _ready():
	is_multiplayer_controlled = true
	# Dynamically attach Authoritative Shield Area for Network Hits
	shield_area = Area2D.new()
	shield_area.collision_mask = 3 # Listen to Ball Layer
	shield_shape = CollisionPolygon2D.new()
	shield_area.add_child(shield_shape)
	add_child(shield_area)
	shield_area.body_entered.connect(_on_shield_body_entered)
	shield_shape.polygon = PackedVector2Array([
		Vector2(-50, -50), Vector2(50, -50),
		Vector2(50, 150), Vector2(-50, 150)
	]) # Approximation for the flag texture, extended downwards to prevent tunneling

@rpc("unreliable", "call_remote", "any_peer")
func mp_update_position(x: float):
	mp_target_x = x

@rpc("reliable", "call_remote", "any_peer")
func goal_saved(ball_name: String):
	# Triggered remotely if the Goalie blocked our ball
	var b = get_parent().get_node("BallsContainer").get_node_or_null(ball_name)
	if b and b.has_method("reject_ball"):
		b.reject_ball()

func _on_shield_body_entered(body: Node2D):
	if multiplayer.multiplayer_peer == null: return
	if "Ball" in body.name and is_multiplayer_authority():
		rpc("goal_saved", body.name)
		
		if body.has_method("reject_ball"):
			body.reject_ball()
		
		if Network.my_role_this_round == Network.PlayerRole.GOALKEEPER:
			var is_fast = false
			if body and body.get("current_y_velocity") != null:
				var trail_limit = body.get("trail_speed_limit") if body.get("trail_speed_limit") != null else -5500
				is_fast = (body.current_y_velocity < trail_limit)
				
			if is_fast:
				_play_voice_over("res://sound/voice_good_save.wav")

func _play_voice_over(file_path: String):
	var stream = load(file_path)
	if stream:
		var player = AudioStreamPlayer.new()
		player.stream = stream
		add_child(player)
		player.play()
		player.finished.connect(player.queue_free)

func _physics_process(delta: float) -> void:
	if multiplayer.multiplayer_peer == null: return
	# Override base entirely
	protecting_goal_in_progress = false 
	var old_x = position.x
	
	if is_multiplayer_authority():
		# Remote Touch Dragging: Goalie can drag anywhere on screen (x-axis)
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.get_connected_joypads().size() > 0:
			var target = get_parent().get_local_mouse_position().x
			target = clamp(target, 80.0, 1000.0)
			position.x = lerp(position.x, float(target), delta * 20.0)
		
		# Always send position update when authoritative so the other peer stays in sync
		rpc("mp_update_position", position.x)
	else:
		# We are the Striker, viewing the remotely manipulated Goalie
		position.x = lerp(position.x, mp_target_x, delta * 15)
		
	# Draw aesthetic ghost trailing if moving sufficiently fast
	if abs(position.x - old_x) > 5.0 and has_method("_add_swish"):
		_add_swish(global_position)

func set_flag(texture: Texture2D) -> void:
	super.set_flag(texture)
	# Expand the goalkeeper's shield area downwards by 100 pixels to prevent fast balls tunneling through
	var poly = shield_shape.polygon
	var new_poly = PackedVector2Array()
	for vertex in poly:
		if vertex.y > 0:
			new_poly.append(Vector2(vertex.x, vertex.y + 100.0))
		else:
			new_poly.append(vertex)
	shield_shape.polygon = new_poly
