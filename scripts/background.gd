extends TextureRect

func _ready():
	if Data.game_mode == C.EURO_MODE:
		texture = load("res://art/grass_euro.png")
	elif Data.game_mode == C.WORLD_MODE:
		texture = load("res://art/grass.png")

