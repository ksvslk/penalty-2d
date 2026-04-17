extends ScrollContainer
@onready var levels_list: VBoxContainer = $LevelsList
var country_button_scene: PackedScene = load("res://scenes/CountryButton.tscn")

func _ready() -> void:
	var levels: Dictionary = Data.get_levels()
	
	# Get sorted keys to ensure proper level order (1, 2, 3, etc.)
	var sorted_keys = levels.keys()
	
	# Loop through with an index counter
	var index := 1
	for country_code in sorted_keys:
		var level_data: Array = levels[country_code]
		
		# Safety check: ensure level_data has the expected values
		if level_data.size() < 2 or level_data[0] == null:
			push_warning("Invalid level data for country code: " + str(country_code))
			continue
		
		var button := country_button_scene.instantiate() as Button
		
		button.country = str(index) + ". " + str(level_data[0])  # Convert to string explicitly
		button.texture = load("res://art/flag/" + str(country_code).replace("\"", "") + ".png")
		button.is_activated = level_data[1] as bool
		
		levels_list.add_child(button)
		
		# Connect with the current index
		button.pressed.connect(get_parent().switch_level_now.bind(index))
		
		index += 1
	
	# Add bottom spacer so last items are not occluded by the back button
	var spacer = ColorRect.new()
	spacer.color = Color(0, 0, 0, 0.7)
	spacer.custom_minimum_size = Vector2(0, 300)
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	levels_list.add_child(spacer)
	
	# Connect to the Data singleton to update the level list when it changes
	Data.level_select_updated.connect(_update_level_select)

func _update_level_select(levels: Dictionary) -> void:
	for country_button in levels_list.get_children():
		if country_button.has_method("activate_button"):
			var texture_path: String = country_button.texture.get_path()
			var country_code = texture_path.get_file().get_slice(".", 0)
			
			if levels.has(country_code) and levels[country_code][1]:
				country_button.activate_button()
