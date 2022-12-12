extends Node2D

onready var release_ball = $ReleaseBall
onready var reach_target = $ReachTarget
onready var tap_to_continue = $TapToContinue


func _ready():
	print("TERE")
	var tween := get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(release_ball, "modulate:a", 1.0, 1)
	tween.tween_property(reach_target, "modulate:a", 1.0, 2)
	tween.tween_property(tap_to_continue, "modulate:a", 1.0, 0.5)
	tween.tween_callback(tap_to_continue, "set_mouse_filter", [tap_to_continue.MOUSE_FILTER_STOP])
	tween.play()


func _on_TapToContinue_gui_input(event):
	if event is InputEventMouseButton and event.is_pressed():
		get_tree().paused = false
		queue_free()


func _on_ColorRect_gui_input(event):
	_on_TapToContinue_gui_input(event)
