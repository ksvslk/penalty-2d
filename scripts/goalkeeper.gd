extends CharacterBody2D

var balls: Array = []
@export var speed: float = 10.0
var swish_scene = load("res://scenes/GSwish.tscn")
@onready var home_position: Vector2 = global_position
var protecting_goal_in_progress := false
@onready var flag: Sprite2D = $Flag
var counter := 0.0
var move_to_center_time_limit := 12
@onready var collision_polygon: CollisionPolygon2D = $CollisionPolygon2D

func _physics_process(delta: float) -> void:
	protecting_goal_in_progress = false
	for b in balls:
		if not is_instance_valid(b): continue # Safety check in case a ball is freed
		
		# Godot 4 uses rad_to_deg()
		var degrees = rad_to_deg(get_angle_to(b.global_position))
		var ball_is_at_right = degrees > 95
		var ball_is_at_left = degrees < 85
		
		if b.global_position.y < 1200 and b.current_y_velocity < -300.0 and (ball_is_at_left or ball_is_at_right):
			var x_cap = b.global_position.x - global_position.x
			var move_vec = Vector2(x_cap, 0)
			
			# move_and_collide still exists on CharacterBody2D
			move_and_collide(move_vec * delta * speed)
			protecting_goal_in_progress = true
			_add_swish(global_position)
			
	if not protecting_goal_in_progress:
		if is_multiplayer_controlled:
			# Manual Control Logic
			var target = get_global_mouse_position().x
			# If we are the network puppet, we move to the received position
			if not is_multiplayer_authority():
				target = remote_target_x
			
			# Clamp movement
			target = clamp(target, 0, 1080)
			position.x = lerp(position.x, target, delta * 10)
		elif counter < move_to_center_time_limit:
			counter += delta * speed
		elif counter >= move_to_center_time_limit:
			var return_vec = Vector2(home_position.x - global_position.x, 0)
			move_and_collide(return_vec * delta * speed)
	elif protecting_goal_in_progress:
		counter = 0

var is_multiplayer_controlled = false
var remote_target_x = 540.0

@rpc("unreliable")
func update_remote_position(x: float):
	remote_target_x = x


func _add_swish(pos: Vector2) -> void:
	# Godot 4 uses instantiate()
	var new_swish = swish_scene.instantiate() as Sprite2D
	new_swish.set_as_top_level(true)
	new_swish.global_position = pos
	# It's better to add the swish to the parent or another layer
	# so it doesn't move with the goalkeeper.
	get_parent().add_child(new_swish)
	new_swish.queue_redraw()
	_remove_swish(new_swish)
	
func _remove_swish(swish: Sprite2D) -> void:
	# Godot 4 Tween API
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	tween.tween_property(swish, "modulate:a", 0.0, 1.0)
	tween.tween_callback(swish.queue_free)

func set_flag(texture: Texture2D) -> void:
	flag.texture = texture
	var tex_size: Vector2 = flag.texture.get_size()
	var width = tex_size.x * 0.26
	var height = tex_size.y * 0.26
	
	# In Godot 4, set the polygon property directly
	collision_polygon.polygon = PackedVector2Array([
		Vector2(-width/2, -height/2),
		Vector2(width/2, -height/2),
		Vector2(width/2, height/2),
		Vector2(-width/2, height/2),
	])
