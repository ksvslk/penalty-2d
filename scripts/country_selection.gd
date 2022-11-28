extends OptionButton
onready var popup = get_popup()
var was_just_dragging = false


func _ready():
	var language = C.get_language()
	var current_country = C.get_country()
	var default_option = -1
	var levels = Data.get_levels()
	for i in range(0, levels.keys().size()):
		var country = levels.keys()[i]
		var texture = load("res://art/flag/" + country + ".png") as Texture
		add_icon_item(texture, levels.get(country)[0], i)
		if country == "br" and current_country == "MISSING":
			default_option = i
		elif country == "gb-sct" and current_country == "gb" and language == "gd":
			default_option = i
		elif country == "gb-wls" and current_country == "gb" and language == "cy": 
			default_option = i
		elif country == "gb-eng" and current_country == "gb":
			default_option = i
		elif country == current_country:
			default_option = i
	Data.change_player_team(levels.keys()[default_option])
	popup.hide_on_item_selection = false
	popup.hide_on_checkable_item_selection = false
	popup.connect("gui_input", self, "_on_popup_gui_input")
	if default_option != -1:
		select(default_option)
	items.sort()


func _on_popup_gui_input(event):
	popup.hide_on_item_selection = false
	popup.hide_on_checkable_item_selection = false

	if event is InputEventScreenDrag:
		print(self.popup.rect_position)
		#self.popup.rect_position += Vector2(0, event.relative.y)
		#was_just_dragging = true
		if self.popup.rect_position.y <= 0 and self.popup.rect_position.y >= -2400:
			self.popup.rect_position += Vector2(0, event.relative.y)
			was_just_dragging = true
	
	if event is InputEventMouseButton:
		if not was_just_dragging:
			popup.hide_on_item_selection = true
			popup.hide_on_checkable_item_selection = true
		was_just_dragging = false


func _on_OptionButton_item_selected(index):
	var levels = Data.get_levels()
	Data.change_player_team(levels.keys()[index])
