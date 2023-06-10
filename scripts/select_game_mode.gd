extends ColorRect

signal game_mode_selected(mode)

func _ready():
	get_tree().paused = true
	if Data.is_first_time():
		visible = true
	else:
		visible = false


func _on_EuroMode_pressed():
	visible = false
	emit_signal("game_mode_selected", C.EURO_MODE)


func _on_WorldMode_pressed():
	visible = false
	emit_signal("game_mode_selected", C.WORLD_MODE)
