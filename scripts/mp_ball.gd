extends "res://scripts/ball.gd"

var target_pos = Vector2()
var target_rot = 0.0

@rpc("unreliable", "call_remote", "any_peer")
func sync_ball_transform(pos: Vector2, rot: float, sleep: bool):
	target_pos = pos
	target_rot = rot
	if not sleep:
		sleeping = false # Preemptively wake up!

@rpc("reliable", "call_remote", "any_peer")
func sync_held_state(h: bool):
	remote_is_held = h

@rpc("reliable", "call_remote", "any_peer")
func rpc_trigger_kick_sound():
	if kick_sound: kick_sound.play()

@rpc("reliable", "call_remote", "any_peer")
func rpc_trigger_super_shot():
	if super_shot: super_shot.play()
	did_get_over_limit = true

func reject_ball():
	if is_multiplayer_authority():
		linear_velocity = Vector2(linear_velocity.x, 3000)
		kick_sound.play()

func init_multiplayer():
	# Godot 4 rigorously unbinds all @onready parent variables when injecting a script dynamically.
	# We MUST physically reconnect all missing native component references to avoid Null Pointer Engine crashes!
	collision_shape_2d = get_node("CollisionShape2D")
	kick_sound = get_node("KickSound")
	timer = get_node("Timer")
	super_shot = get_node("SuperShot")

func _input_event(_viewport, event, _shape_idx):
	if not is_multiplayer_authority(): return
	super(_viewport, event, _shape_idx)
	if event is InputEventScreenTouch and event.pressed:
		sleeping = false # Force Godot to explicitly securely restart the physics computation loop!

func _input(event):
	if not is_multiplayer_authority(): return
	super(event)

var _last_did_get_over_limit = false

func _process(_delta):
	if not is_multiplayer_authority(): return
	super(_delta)
	
	if did_get_over_limit and not _last_did_get_over_limit:
		rpc("rpc_trigger_super_shot")
	_last_did_get_over_limit = did_get_over_limit

func _integrate_forces(state: PhysicsDirectBodyState2D):
	if multiplayer.multiplayer_peer == null: return
	if not is_multiplayer_authority():
		# Clients now explicitly cancel out local physics so the lerp smoothly dominates
		state.linear_velocity = Vector2.ZERO
		state.angular_velocity = 0.0
		return

	if held:
		var linear_vel = get_global_mouse_position() - global_position
		if get_global_mouse_position().y < 1200:
			linear_vel /= 3
			kick_sound.play()
			rpc("rpc_trigger_kick_sound")
			held = false
			mediator.holding_ball = false
			rpc("sync_held_state", false)
		
		state.linear_velocity = linear_vel
		state.linear_velocity *= mouse_drag_scale
		rpc("sync_held_state", true)
		
	current_y_velocity = state.linear_velocity.y

var sleep_sent = false

func _physics_process(_delta):
	if multiplayer.multiplayer_peer == null: return
	if is_multiplayer_authority():
		# Host broadcasts its absolute truth dynamically! Throttle sleep packets to prevent ENet queue DOS flooding.
		if sleeping:
			if not sleep_sent:
				rpc("sync_ball_transform", global_position, rotation, true)
				sleep_sent = true
		else:
			sleep_sent = false
			rpc("sync_ball_transform", global_position, rotation, false)
	else:
		# Client perfectly mimics host visually without fighting local engine physics!
		if target_pos != Vector2():
			var old_pos = global_position
			global_position = global_position.lerp(target_pos, _delta * 20)
			rotation = lerp_angle(rotation, target_rot, _delta * 20)
			current_y_velocity = (global_position.y - old_pos.y) / _delta
			
	# Trails run identically for both native and remote authority
	if current_y_velocity < trail_speed_limit and did_get_over_limit:
		_add_trail()
	if global_position.y <= 111:
		set_collision_mask_value(4, false)
	else:
		set_collision_mask_value(4, true)
