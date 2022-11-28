extends Node
class_name Master


onready var level_scroller = $CanvasLayer/LevelScroller
onready var mediator = get_node("Level")
onready var levels_list = $CanvasLayer/LevelScroller/LevelsList
var scrolling := false
var country_button = load("res://scenes/CountryButton.tscn")
onready var select_country = $CanvasLayer/SelectCountry


func _ready():
	get_tree().paused = true
	var levels = Data.get_levels()
	for index in range(0, levels.size()):
		var button = country_button.instance() as CountryButton
		button.country = str(index + 1) + ". " + levels.values()[index][0]
		button.texture = load("res://art/flag/" + levels.keys()[index] + ".png")
		button.is_activated = levels.values()[index][1] as bool
		levels_list.add_child(button)
		button.connect("pressed", self, "_switch_level", [index+1])
	Data.connect("level_select_updated", self, "_update_level_select")
	if Data.is_first_time() == true:
		select_country.initialize_select_country()
		select_country.visible = true
	else:
		get_tree().paused = false


func _update_level_select(levels:Dictionary):
	for country_button in levels_list.get_children():
		if country_button is CountryButton:
			var ccode = country_button.texture.get_path().get_file().get_slice(".", 0)
			if levels.get(ccode)[1] == true:
				country_button.activate_button() 


func _switch_level(nr:int) -> void:
	get_tree().paused = true
	Data.load_level(nr)
	level_scroller.visible = !level_scroller.visible

	
func _on_Button_pressed():
	level_scroller.visible = !level_scroller.visible


func _on_AddBall_pressed():
	mediator.ball_count += 1
	mediator.add_ball()


func _on_RemoveBall_pressed():
	if mediator.ball_count > 1:
		mediator.ball_count -= 1
		mediator.remove_ball()
		

func _on_Continue_gui_input(event):
	if event.is_pressed():
		Data.next_level()


