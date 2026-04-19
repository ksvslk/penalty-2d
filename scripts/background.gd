extends TextureRect

func _ready():
	if not texture or texture.resource_path == "":
		texture = load("res://art/grass.png")
