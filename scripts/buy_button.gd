extends Button

func _ready():
	if text != "...":
		visible = true
		
		
func _set(property, value):
	if property == "text" and value != "...":
		visible = true
