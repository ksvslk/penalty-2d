extends Node
class_name Master


var scrolling := false
onready var mediator = get_node("Level")
onready var select_country = $CanvasLayer/SelectCountry


func _ready():
	get_tree().paused = true
	if Data.is_first_time() == true:
		select_country.initialize_select_country()
		select_country.visible = true
	else:
		get_tree().paused = false


func _on_RemoveBall_pressed():
	if mediator.ball_count > 1:
		mediator.ball_count -= 1
		mediator.remove_ball()
		

func _on_Continue_gui_input(event):
	if event.is_pressed():
		Data.next_level()


func _on_OptionsContainer_add_ball():
	mediator.ball_count += 1
	mediator.add_ball()


func _on_OptionsContainer_switch_level(nr):
	get_tree().paused = true
	Data.load_level(nr)
