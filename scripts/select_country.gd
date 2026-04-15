extends ColorRect

var country_select_scene: PackedScene = load("res://scenes/CountrySelectButton.tscn")
@onready var country_list: VBoxContainer = $CountryScroller/CountryList
@onready var selected_country: Button = $VBoxContainer/SelectedCountry # Assuming it's a button-like node
@onready var v_box_container: VBoxContainer = $VBoxContainer
@onready var country_scroller: ScrollContainer = $CountryScroller

signal team_selection_done

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Pause the game while the selection screen is active
	get_tree().paused = true
	if Data.is_first_time():
		initialize_select_country()
		visible = true
	else:
		visible = false
		team_selection_done.emit()
		# If not first time, unpause immediately as this screen won't be shown
		get_tree().paused = false


func initialize_select_country() -> void:
	var select_country_buttons: Array = []
	var language := C.get_language()
	var current_country := C.get_country()
	var default_option := -1
	var levels: Dictionary = Data.get_levels()

	for country_flag in levels.keys():
		var texture: Texture2D = load("res://art/flag/" + country_flag + ".png")
		# Godot 4 uses instantiate()
		var select_button := country_select_scene.instantiate() as Button # Cast to base type
		select_button.flag = country_flag
		select_button.texture = texture
		select_button.country = levels[country_flag][0]
		select_country_buttons.push_back(select_button)
	
	# Godot 4's sort_custom takes a Callable directly
	select_country_buttons.sort_custom(country_name_ascending)
	
	for i in range(select_country_buttons.size()):
		var button = select_country_buttons[i]
		
		# Logic to determine the default selected country
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
			
		# Godot 4 signal connection with arguments using .bind()
		button.pressed.connect(_set_new_default_team.bind(button.flag, button.country))
		country_list.add_child(button)
		
	# Safeguard: if no specific country was matched, default to the first in the list
	if default_option == -1 and not select_country_buttons.is_empty():
		default_option = 0
		
	if default_option != -1:
		var default_button = select_country_buttons[default_option]
		_set_new_default_team(default_button.flag, default_button.country)


# Custom sort function used by Array.sort_custom
func country_name_ascending(a, b) -> bool:
	return a.country < b.country


func _set_new_default_team(flag: String, country: String) -> void:
	Data.change_player_team(flag)
	var texture: Texture2D = load("res://art/flag/" + flag + ".png")
	selected_country.flag = flag
	selected_country.texture = texture
	selected_country.country = country
	selected_country.update_info() # Assumes this method exists on the button script
	v_box_container.visible = true
	country_scroller.visible = false


func _on_SelectedCountry_pressed() -> void:
	v_box_container.visible = false
	country_scroller.visible = true


func _on_ConfirmButton_pressed() -> void:
	team_selection_done.emit()
	visible = false
	# Unpause the game now that the selection is complete
	get_tree().paused = false
