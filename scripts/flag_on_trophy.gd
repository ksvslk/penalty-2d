extends TextureRect

func _ready():
	var team = Data.get_player_team()
	texture = load("res://art/flag/" + team + ".png")
