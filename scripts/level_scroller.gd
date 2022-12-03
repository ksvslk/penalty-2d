extends ScrollContainer

onready var levels_list = $LevelsList
var country_button = load("res://scenes/CountryButton.tscn")

func _ready():
	var levels = Data.get_levels()
	for index in range(0, levels.size()):
		var button = country_button.instance() as CountryButton
		button.country = str(index + 1) + ". " + levels.values()[index][0]
		button.texture = load("res://art/flag/" + levels.keys()[index] + ".png")
		button.is_activated = levels.values()[index][1] as bool
		levels_list.add_child(button)
		button.connect("pressed", get_parent(), "switch_level", [index+1])
	Data.connect("level_select_updated", self, "_update_level_select")


func _update_level_select(levels:Dictionary):
	for country_button in levels_list.get_children():
		if country_button is CountryButton:
			var ccode = country_button.texture.get_path().get_file().get_slice(".", 0)
			if levels.get(ccode)[1]:
				country_button.activate_button() 
