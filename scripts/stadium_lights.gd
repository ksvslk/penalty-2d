extends Node2D

@onready var positions: Node2D = $Positions
@onready var lights: Node = $Lights # Assuming $Lights has a script attached
@onready var timer: Timer = $Timer
@export var enable_stadium_lights := false # Note: This variable is not used in the script.
@export var node_path := NodePath()
@onready var level: Node2D = get_node(node_path)


func _ready() -> void:
	_on_Lights_lights_completely_off()


func _enable_stadium_lights() -> void:
	visible = true
	timer.start()
	# In Godot 4, use 'process_mode' to enable/disable processing.
	# Note: This script does not have a _process() or _physics_process() function.
	process_mode = Node.PROCESS_MODE_INHERIT
	_change_lights_target_positions()
	if lights.lights_off:
		lights.on()


func disable_stadium_lights() -> void:
	if not lights.lights_off:
		lights.off()


func get_random_position_node_pos() -> Vector2:
	var children = positions.get_children()
	if children.is_empty():
		return Vector2.ZERO # Avoid a crash if there are no position nodes
	
	# In Godot 4, use randi_range() for a random integer in a range.
	var random_index = randi_range(0, children.size() - 1)
	return children[random_index].global_position


func _on_Timer_timeout() -> void:
	_change_lights_target_positions()


func _change_lights_target_positions() -> void:
	for child_light in lights.get_children():
		# This assumes each child of $Lights has this property.
		child_light.current_target_destination = get_random_position_node_pos()


func _on_Level_level_passed() -> void:
	_enable_stadium_lights()


func _on_Level_start_level() -> void:
	disable_stadium_lights()


func _on_Lights_lights_completely_off() -> void:
	visible = false
	timer.stop()
	# In Godot 4, use 'process_mode' to disable processing.
	process_mode = Node.PROCESS_MODE_DISABLED


func _on_Lights_lights_completely_on() -> void:
	pass
