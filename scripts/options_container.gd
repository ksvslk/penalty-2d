extends Control

onready var options_list = $OptionsList
onready var options = $Options
var currently_visible_suboption = null

onready var level_scroller = $LevelScroller

signal add_ball
signal switch_level

func _on_Options_pressed():
	if not currently_visible_suboption:
		if options_list.visible:
			options_list.visible = false
			options.text = "Options"
		else:
			options_list.visible = true
			options.text = "< Back"
	else:
		currently_visible_suboption.visible = false
		currently_visible_suboption = null
		options.text = "Options"


func _on_Levels_pressed():
	level_scroller.visible = true
	options_list.hide()
	currently_visible_suboption = level_scroller
	options.text = "< Back"


func _on_AddBall_pressed():
	options_list.hide()
	emit_signal("add_ball")
	

func switch_level(index):
	_on_Options_pressed()
	emit_signal("switch_level", index)
