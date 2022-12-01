extends ColorRect


func _set(property, value):
	if property == "visible":
		if value == true:
			get_tree().paused = true
			visible = true
		elif value == false:
			visible = false
			get_tree().paused = false
