extends ColorRect

var country_select = load("res://scenes/CountrySelectButton.tscn")
onready var country_list = $CountryScroller/CountryList
onready var selected_country = $VBoxContainer/SelectedCountry
onready var v_box_container = $VBoxContainer
onready var country_scroller = $CountryScroller


signal team_selection_done

func _ready():
	if Data.is_first_time():
		initialize_select_country()
		visible = true
	else:
		emit_signal("team_selection_done")



func initialize_select_country():
	var select_country_buttons = []
	var language = C.get_language()
	var current_country = C.get_country()
	var default_option = -1
	var levels = Data.get_levels()

	for i in range(0, levels.keys().size()):
		var country = levels.keys()[i]
		var texture = load("res://art/flag/" + country + ".png") as Texture
		var select_button = country_select.instance() as CountrySelectButton
		select_button.flag = country
		select_button.texture = texture
		select_button.country = levels.get(country)[0]
		select_country_buttons.push_back(select_button)
	select_country_buttons.sort_custom(self, "country_name_ascending")
	
	for i in range(0, select_country_buttons.size()):
		var button = select_country_buttons[i] as CountrySelectButton
		if button.flag == "br" and current_country == "MISSING":
			default_option = i
		elif button.flag == "gb-sct" and current_country == "gb" and language == "gd":
			default_option = i
		elif button.flag == "gb-wls" and current_country == "gb" and language == "cy": 
			default_option = i
		elif button.flag == "gb-eng" and current_country == "gb":
			default_option = i
		elif button.flag == current_country:
			default_option = i
		button.connect("pressed", self, "_set_new_default_team", [button.flag, button.country])
		country_list.add_child(button)
	_set_new_default_team(select_country_buttons[default_option].flag, select_country_buttons[default_option].country)


func country_name_ascending(a:CountrySelectButton, b:CountrySelectButton):
	return a.country < b.country;


func _set_new_default_team(flag:String, country:String):
	Data.change_player_team(flag)
	var texture = load("res://art/flag/" + flag + ".png") as Texture
	selected_country.flag = flag
	selected_country.texture = texture
	selected_country.country = country
	selected_country.update_info()
	v_box_container.visible = !v_box_container.visible
	country_scroller.visible = !country_scroller.visible


func _on_SelectedCountry_pressed():
	v_box_container.visible = !v_box_container.visible
	country_scroller.visible = !country_scroller.visible


func _on_ConfirmButton_pressed():
	emit_signal("team_selection_done")
	visible = false
