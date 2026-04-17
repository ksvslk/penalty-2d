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
			
	if is_multiplayer_controlled:
		protecting_goal_in_progress = false # Override AI completely
		if is_multiplayer_authority():
			# Remote Touch Dragging: Goalie can drag anywhere on screen (x-axis)
			# Only sync if touching the screen
			if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.get_connected_joypads().size() > 0:
				var target = get_global_mouse_position().x
				target = clamp(target, 80, 1000)
				position.x = lerp(position.x, target, delta * 20)
				rpc("update_remote_position", position.x)
		else:
			# We are the Striker, viewing the remotely manipulated Goalie
			position.x = lerp(position.x, remote_target_x, delta * 15)
	else:
		if not protecting_goal_in_progress:
			if counter < move_to_center_time_limit:
				counter += delta * speed
			elif counter >= move_to_center_time_limit:
				var return_vec = Vector2(home_position.x - global_position.x, 0)
				move_and_collide(return_vec * delta * speed)
		elif protecting_goal_in_progress:
			counter = 0

var is_multiplayer_controlled = false
var remote_target_x = 540.0

var shield_area: Area2D
var shield_shape: CollisionPolygon2D

func _ready():
	if Network.connected_peer_id != 0:
		is_multiplayer_controlled = true
		
	# Dynamically attach Authoritative Shield Area for Network Hits
	shield_area = Area2D.new()
	shield_area.collision_mask = 3 # Listen to Ball Layer
	shield_shape = CollisionPolygon2D.new()
	shield_area.add_child(shield_shape)
	add_child(shield_area)
	shield_area.body_entered.connect(_on_shield_body_entered)

func _on_shield_body_entered(body: Node2D):
	if body is Ball and is_multiplayer_authority() and is_multiplayer_controlled:
		rpc("goal_saved", body.name)

@rpc("unreliable", "call_remote", "any_peer")
func update_remote_position(x: float):
	remote_target_x = x

@rpc("reliable", "call_remote", "any_peer")
func goal_saved(ball_name: String):
	# Triggered remotely if the Goalie blocked our ball
	var ball = get_parent().get_node("BallsContainer").get_node_or_null(ball_name)
	if ball and ball is Ball and ball.is_multiplayer_authority():
		# The authoritative ball bounces backward, denying the goal
		ball.linear_velocity = Vector2(ball.linear_velocity.x, 3000)
		ball.kick_sound.play()


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
	shield_shape.polygon = collision_polygon.polygon
