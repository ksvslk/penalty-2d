extends "res://scripts/ball.gd"

var was_shot := false
var was_held_last_frame := false

@rpc("reliable", "call_remote", "any_peer")
func launch_ball_remote(unshifted_pos: Vector2, vel: Vector2):
	super(unshifted_pos, vel)
	was_shot = true
	if vel.y < trail_speed_limit:
		did_get_over_limit = true
		if super_shot: super_shot.play()

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
	print("[MP Ball] init_multiplayer (first solution): name=", name)

func _input_event(_viewport, event, _shape_idx):
	if not is_multiplayer_authority(): return
	super(_viewport, event, _shape_idx)

func _input(event):
	if not is_multiplayer_authority(): return
	super(event)

func _integrate_forces(state: PhysicsDirectBodyState2D):
	super(state)
	if is_multiplayer_authority():
		if was_held_last_frame and not held:
			was_shot = true
		was_held_last_frame = held

func _physics_process(_delta):
	if multiplayer.multiplayer_peer == null: return
	
	# Trails and mask overrides for multiplayer local physics
	if current_y_velocity < trail_speed_limit and did_get_over_limit:
		_add_trail()
		
	if global_position.y <= 111:
		set_collision_mask_value(4, false)
	else:
		set_collision_mask_value(4, true)
