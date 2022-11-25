extends Node2D

onready var positions = $Positions
onready var lights = $Lights
export var enable_stadium_lights = false
onready var timer = $Timer
export var node_path := NodePath()
onready var level = get_node(node_path) as Node2D
var lights_on := 0

func _ready():
	_on_Lights_lights_completely_off()


func enable_stadium_lights() -> void:
	print("enable_stadium_lights")
	visible = true
	timer.start()
	set_process(true)
	_change_lights_target_positions()
	if lights.lights_off:
		lights.on()


func disable_stadium_lights() -> void:
	print("disable_stadium_lights")
	if not lights.lights_off:
		lights.off()


func get_random_position_node_pos() -> Vector2:
	return positions.get_children()[rand_range(0, positions.get_children().size() - 1)].global_position


func _on_Timer_timeout():
	_change_lights_target_positions()


func _change_lights_target_positions():
	for c in lights.get_children():
		c.current_target_destination = get_random_position_node_pos()


func _on_Level_level_passed():
	enable_stadium_lights()


func _on_Level_start_level():
	disable_stadium_lights()


func _on_Lights_lights_completely_off():
	print("_on_Lights_lights_completely_off")
	visible = false
	timer.stop()
	set_process(false)


func _on_Lights_lights_completely_on():
	pass
