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
		Vector2(50, 50), Vector2(-50, 50)
	]) # Approximation for the flag texture

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

func _physics_process(delta: float) -> void:
	if multiplayer.multiplayer_peer == null: return
	# Override base entirely
	protecting_goal_in_progress = false 
	var old_x = position.x
	
	if is_multiplayer_authority():
		# Remote Touch Dragging: Goalie can drag anywhere on screen (x-axis)
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.get_connected_joypads().size() > 0:
			var target = get_local_mouse_position().x + position.x # get_local_mouse_position() evaluates relative to the origin of the node.
			# Wait! By definition, 'get_local_mouse_position()' on a CharacterBody returns relative offset!
			# To get the local coordinates relative to the PARENT level space where position.x exists:
			target = get_parent().get_local_mouse_position().x
			target = clamp(target, 80.0, 1000.0)
			position.x = lerp(position.x, float(target), delta * 20.0)
			rpc("mp_update_position", position.x)
	else:
		# We are the Striker, viewing the remotely manipulated Goalie
		position.x = lerp(position.x, mp_target_x, delta * 15)
		
	# Draw aesthetic ghost trailing if moving sufficiently fast
	if abs(position.x - old_x) > 5.0 and has_method("_add_swish"):
		_add_swish(global_position)
