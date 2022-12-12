extends Control


func _on_Start_gui_input(event):
	if event is InputEventMouseButton and event.is_pressed():
		hide()
		get_tree().paused = false
		queue_free()
