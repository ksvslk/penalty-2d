extends Button


func _ready():
	_set_texture_based_on_os()
	if GPack.plugin:
		set_access(GPack.is_signed_in())
		GPack.plugin.connect(GPack.s_on_signed_in_status_changed, self, "set_access")


func set_access(b):
	disabled = !b


func _set_texture_based_on_os():
	match OS.get_name():
		"Android":
			text = "Play Games"
			icon = load("res://art/games_controller_grey.png")
		"iOS":
			text = "Game Center"
			icon = load("res://art/ios/game_center.png")
