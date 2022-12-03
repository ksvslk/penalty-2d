extends KinematicBody2D
var balls = []
export(float) var speed := 10.0
var swish_scene = load("res://scenes/GSwish.tscn")
onready var home_position = global_position
var protecting_goal_in_progress = false
onready var flag = $Flag
var counter := 0.0
var move_to_center_time_limit := 12
onready var collision_polygon = $CollisionPolygon2D


func _physics_process(delta):
	protecting_goal_in_progress = false
	for b in balls:
		var degrees = rad2deg(get_angle_to(b.global_position))
		var ball_is_at_right = degrees > 95
		var ball_is_at_left = degrees < 85 
		if b.global_position.y < 1200 and b.current_y_velocity < -300.0 and (ball_is_at_left or ball_is_at_right):
			var x_cap = b.global_position.x - global_position.x
			var move = Vector2(x_cap, 0)
			move_and_collide(move * delta * speed)
			protecting_goal_in_progress = true
			_add_swish(global_position)
	if not protecting_goal_in_progress:
		if counter < move_to_center_time_limit:
			counter += delta * speed
		elif counter >= move_to_center_time_limit:
			move_and_collide(Vector2(home_position.x - global_position.x, 0) * delta * speed)
	elif protecting_goal_in_progress:
		counter = 0


func _add_swish(pos):
	var new_swish = swish_scene.instance() as Sprite
	new_swish.set_as_toplevel(true)
	new_swish.global_position = pos
	add_child(new_swish)
	new_swish.update()
	_remove_swish(new_swish)
	

func _remove_swish(swish):
	var tween := create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	tween.tween_property(swish, "modulate:a", 0.0,1)
	tween.tween_callback(swish, "queue_free")
	tween.play()


func set_flag(texture):
	flag.texture = texture
	var width = flag.texture.get_size().x * 0.26
	var height = flag.texture.get_size().y * 0.26
	$CollisionPolygon2D.set_polygon(
		[
			Vector2(-width/2,-height/2),
			Vector2(width/2, -height/2),
			Vector2(width/2,height/2),
			Vector2(-width/2, height/2),
		]
	)
