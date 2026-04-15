extends RigidBody2D
class_name Ball

var mediator
var held = false
@onready var collision_shape_2d = $CollisionShape2D
@export var mouse_drag_scale = 20
@onready var kick_sound = $KickSound
@onready var timer = $Timer
@onready var super_shot = $SuperShot

var current_y_velocity = 0.0
var football_trail = load("res://scenes/FootballTrail.tscn")
var trail_speed_limit := -5500
var did_get_over_limit := false

func _ready():
	# The 'use_parent_material' property was removed in Godot 4.
	# Material inheritance is now the default behavior, so this line is no longer needed.
	pass


func _input_event(_viewport, event, _shape_idx):
	if event is InputEventScreenTouch and get_global_mouse_position().y > 1200 and mediator.round_is_active and not mediator.holding_ball: # check if left click is pressed on the body
		mediator.holding_ball = true
		held = event.pressed
		timer.start()
		did_get_over_limit = false


func activate_bonus_patch():
	$BonusPatch.visible = true


func _add_trail() -> void:
	# Godot 4 uses instantiate() instead of instance()
	var trail = football_trail.instantiate() as Sprite2D
	trail.set_as_top_level(true)
	trail.global_position = global_position
	get_parent().add_child(trail)


func _input(event): # check if left click is released even outside of the body
	if event is InputEventScreenTouch and not event.pressed:
		if held:
			if current_y_velocity < trail_speed_limit:
				super_shot.play()
				did_get_over_limit = true
				unlock_ball_related_achievements()
			else:
				C.fast_shot_counter = 0
				kick_sound.play()
			mediator.swipe_counter += 1
		held = false
		mediator.holding_ball = false
		mediator.remove_swish(name)


func unlock_ball_related_achievements():
	C.fast_shot_counter += 1
	if C.fast_shot_counter == 5:
		GPack.unlock_achievement(C.achievement_fast_shot_5x)
	if C.fast_shot_counter == 15:
		GPack.unlock_achievement(C.achievement_15_x_fast_shot)


func _integrate_forces(state: PhysicsDirectBodyState2D):
	if held:
		var linear_vel = get_global_mouse_position() - global_position
		if get_global_mouse_position().y < 1200:
			linear_vel /= 3
			kick_sound.play()
			held = false
			mediator.holding_ball = false
		state.linear_velocity = linear_vel
		state.linear_velocity *= mouse_drag_scale
	current_y_velocity = state.linear_velocity.y





func _process(delta):
	if held:
		mediator.add_swish(name, [global_position, get_global_mouse_position()])


func set_flag(country: String):
	var flag_texture = load("res://art/flag/" + country + ".png")
	$Flag.texture = flag_texture
	
	
func is_in_bounds(pos: Vector2 = global_position) -> bool:
	var c = collision_shape_2d.shape as CircleShape2D
	# Godot 4 uses 'get_viewport().size' instead of 'get_viewport().get_visible_rect().size'
	var viewport_x = get_viewport().size.x
	var viewport_y = get_viewport().size.y - 185
	var c_plus_x = pos.x + c.radius
	var c_minus_x = pos.x - c.radius
	var c_plus_y = pos.y + c.radius
	var c_minus_y = pos.y - c.radius
	if c_plus_x > viewport_x or c_minus_x < 0 or c_plus_y > viewport_y or c_plus_y < 0:
		return false
	return true





func _enter_tree():
	# Configuration for MultiplayerSynchronizer would typically be done in the editor
	# But we can try to set it up via script if the node exists, or just rely on the Spawner.
	set_multiplayer_authority(1) # Default to server, will be updated by spawner

func _physics_process(delta):
	# only process physics if we are the authority
	if is_multiplayer_authority():
		if current_y_velocity < trail_speed_limit and did_get_over_limit:
			_add_trail()
		if global_position.y <= 111:
			set_collision_mask_value(4, false)
		else:
			set_collision_mask_value(4, true)
