extends TextureRect

func _ready():
	var team = Data.get_player_team()
	texture = load(C.get_flag_path() + team + C.get_extension())
