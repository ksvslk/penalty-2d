extends Node
onready var level_scroller = $CanvasLayer/LevelScroller
onready var mediator = get_node("Level")
onready var levels_list = $CanvasLayer/LevelScroller/LevelsList

var country_button = load("res://scenes/CountryButton.tscn")

func _ready():
	var levels = Data.get_levels()
	for index in range(0, levels.size()):
		var button = country_button.instance() as CountryButton
		button.country = str(index + 1) + ". " + levels.values()[index][0]
		button.texture = load("res://art/flag/" + levels.keys()[index] + ".png")
		button.is_activated = levels.values()[index][1] as bool
		levels_list.add_child(button)
		button.connect("pressed", self, "_switch_level", [index+1])
		

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
