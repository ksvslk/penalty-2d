extends "res://scripts/ball.gd"

var was_shot := false
var was_held_last_frame := false

var remote_linear_velocity := Vector2.ZERO
var remote_rotation := 0.0
var remote_angular_velocity := 0.0
var has_remote_state := false

@rpc("unreliable", "call_remote", "any_peer")
func sync_ball_state(unshifted_pos: Vector2, vel: Vector2, rot: float, ang_vel: float):
	remote_pos = unshifted_pos + Vector2(0, get_local_shift_y())
	remote_linear_velocity = vel
	remote_rotation = rot
	remote_angular_velocity = ang_vel
	has_remote_state = true

@rpc("unreliable", "call_remote", "any_peer")
func update_ball_drag(unshifted_pos: Vector2):
	super(unshifted_pos)
	remote_linear_velocity = Vector2.ZERO
	remote_angular_velocity = 0.0
	has_remote_state = true
	# Instantly move to drag position on goalkeeper side for maximum responsiveness
	if not is_multiplayer_authority():
		global_position = remote_pos

@rpc("reliable", "call_remote", "any_peer")
func launch_ball_remote(unshifted_pos: Vector2, vel: Vector2):
	super(unshifted_pos, vel)
	was_shot = true
	if vel.y < trail_speed_limit:
		did_get_over_limit = true
		if super_shot: super_shot.play()
	# Update remote variables immediately and teleport for zero launch lag
	remote_pos = unshifted_pos + Vector2(0, get_local_shift_y())
	remote_linear_velocity = vel
	has_remote_state = true
	if not is_multiplayer_authority():
		global_position = remote_pos
		global_rotation = 0.0

func reject_ball():
	linear_velocity = Vector2(linear_velocity.x, 3000)
	kick_sound.play()

func init_multiplayer():
	collision_shape_2d = get_node("CollisionShape2D")
	kick_sound = get_node("KickSound")
	timer = get_node("Timer")
	super_shot = get_node("SuperShot")
	
	# Enable continuous collision detection to prevent fast tunneling shots
	continuous_cd = RigidBody2D.CCD_MODE_CAST_RAY
	print("[MP Ball] init_multiplayer: name=", name)

func _input_event(_viewport, event, _shape_idx):
	if not is_multiplayer_authority(): return
	super(_viewport, event, _shape_idx)

func _input(event):
	if not is_multiplayer_authority(): return
	super(event)

func _integrate_forces(state: PhysicsDirectBodyState2D):
	if is_multiplayer_authority():
		super(state)
		if was_held_last_frame and not held:
			was_shot = true
		was_held_last_frame = held

func _physics_process(delta):
	if multiplayer.multiplayer_peer == null: return
	
	if is_multiplayer_authority():
		freeze = false
		
		# Authoritative ball (Striker): continuously broadcast its physical state
		if Network.connected_peer_id != 0:
			var unshifted_pos = global_position - Vector2(0, get_local_shift_y())
			rpc("sync_ball_state", unshifted_pos, linear_velocity, rotation, angular_velocity)
	else:
		freeze = true
		freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
		
		if has_remote_state:
			if remote_is_held:
				# Track drag directly for maximum responsiveness
				global_position = remote_pos
				global_rotation = 0.0
				current_y_velocity = 0.0
			else:
				# Smoothly interpolate position and rotation during flight/rest
				global_position = global_position.lerp(remote_pos, delta * 25.0)
				global_rotation = lerp_angle(global_rotation, remote_rotation, delta * 25.0)
				current_y_velocity = remote_linear_velocity.y
				
	# Trails and mask overrides for multiplayer local physics
	if current_y_velocity < trail_speed_limit and did_get_over_limit:
		_add_trail()
		
	if global_position.y <= 111:
		set_collision_mask_value(4, false)
	else:
		set_collision_mask_value(4, true)
