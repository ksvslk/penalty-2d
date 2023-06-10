extends ColorRect

var euro_team_select = load("res://scenes/CountrySelectButton.tscn")
onready var team_list = $TeamScroller/TeamList
onready var selected_team = $VBoxContainer/SelectedTeam
onready var v_box_container = $VBoxContainer
onready var team_scroller = $TeamScroller

signal euro_team_selection_done


func _on_SelectGameMode_game_mode_selected(mode):
	if (mode == C.EURO_MODE):
		initialize_club_selection()
		visible = true
	else:
		visible = false


func initialize_club_selection():
	var select_country_buttons = []
	var current_country = C.get_country()
	var default_option = -1
	var levels = Data.get_euro_levels()

	for i in range(0, levels.keys().size()):
		var country = levels.keys()[i]
		var texture = load("res://art/team_flag/" + country + ".jpg") as Texture
		var select_button = euro_team_select.instance() as CountrySelectButton
		select_button.flag = country
		select_button.texture = texture
		select_button.country = levels.get(country)[0]
		select_country_buttons.push_back(select_button)
	select_country_buttons.sort_custom(self, "country_name_ascending")
	
	for i in range(0, select_country_buttons.size()):
		var button = select_country_buttons[i] as CountrySelectButton
		button.connect("pressed", self, "_set_new_default_team", [button.flag, button.country])
		team_list.add_child(button)
	default_option = 0
	_set_new_default_team(select_country_buttons[default_option].flag, select_country_buttons[default_option].country)


func _set_new_default_team(flag:String, country:String):
	Data.change_player_team(flag)
	var texture = load("res://art/team_flag/" + flag + ".jpg") as Texture
	selected_team.flag = flag
	selected_team.texture = texture
	selected_team.country = country
	selected_team.update_info()
	v_box_container.visible = !v_box_container.visible
	team_scroller.visible = !team_scroller.visible


func _on_SelectedTeam_pressed():
	v_box_container.visible = !v_box_container.visible
	team_scroller.visible = !team_scroller.visible


func _on_ConfirmButton_pressed():
	Data.set_team_and_current_level("212", selected_team.flag)
	Data.initial_game_load()
	emit_signal("euro_team_selection_done")
	visible = false


func country_name_ascending(a:CountrySelectButton, b:CountrySelectButton):
	return a.country < b.country;
