extends Button


func _ready():
	_set_texture_based_on_os()
	if GPack.plugin:
		set_access(GPack.is_signed_in())
		GPack.plugin.connect(GPack.s_on_signed_in_status_changed, Callable(self, "set_access"))

#popup.connect("gui_input", Callable(self, "_on_popup_gui_input"))
func set_access(b:int):
	if b == 1:
		disabled = false
	else:
		disabled = true
	#disabled = !b


func _set_texture_based_on_os():
	match OS.get_name():
		"Android":
			text = "Play Games"
			icon = load("res://art/games_controller_grey.png")
		"iOS":
			text = "Game Center"
			icon = load("res://art/ios/game_center.png")
