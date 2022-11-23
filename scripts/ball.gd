extends RigidBody2D
class_name Ball

var mediator
var held = false
onready var collision_shape_2d = $CollisionShape2D
export var mouse_drag_scale = 20
onready var kick_sound = $KickSound
onready var timer = $Timer

var current_y_velocity = 0.0


func _input_event(viewport, event, shape_idx):
	if event is InputEventScreenTouch and get_global_mouse_position().y > 1200 and mediator.round_is_active: # check if left click is pressed on the body
		held = event.pressed
		timer.start()


func _input(event): # check if left click is released even outside of the body
	if event is InputEventScreenTouch and not event.pressed:
		if held:
			kick_sound.play()
		held = false
		mediator.remove_swish(name)


func _integrate_forces(state):
	if held:
		var linear_vel = get_global_mouse_position() - global_position
		if get_global_mouse_position().y < 1200:
			linear_vel /= 3
			kick_sound.play()
			held = false
		state.linear_velocity = linear_vel
		state.linear_velocity *= mouse_drag_scale
	current_y_velocity = state.linear_velocity.y


func _physics_process(delta):
	if global_position.y <= 111:
		set_collision_mask_bit(3, false)
	else:
		set_collision_mask_bit(3, true)
		
func _process(delta):
	if held:
		mediator.add_swish(name, [global_position, get_global_mouse_position()])


func is_in_bounds(pos: Vector2 = global_position) -> bool:
	var c = collision_shape_2d.shape as CircleShape2D
	var viewport_x = get_viewport().get_visible_rect().size.x
	var viewport_y =  get_viewport().get_visible_rect().size.y - 185
	var c_plus_x = pos.x + c.radius
	var c_minus_x = pos.x - c.radius
	var c_plus_y = pos.y + c.radius
	var c_minus_y = pos.y - c.radius
	if c_plus_x > viewport_x or c_minus_x < 0 or c_plus_y > viewport_y or c_plus_y < 0:
		return false
	return true
	


func _on_Timer_timeout():
	held = false
	mediator.remove_swish(name)
