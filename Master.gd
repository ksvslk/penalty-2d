extends Node
class_name Master

var scrolling := false
onready var mediator = get_node("Level")
onready var watch_ad = $Level/WatchAd


func _ready():
	if GPack.plugin:
		GPack.plugin.connect(GPack.s_reward_earned, self, "_on_BonusList_add_ball")
	

func _on_RemoveBall_pressed():
	if mediator.ball_count > 1:
		mediator.ball_count -= 1
		mediator.remove_ball()
		

func _on_Continue_gui_input(event):
	if event.is_pressed():
		Data.next_level()


func _on_OptionsContainer_switch_level(nr):
	get_tree().paused = true
	Data.load_level(nr)


func _on_BonusList_add_ball(rewardType:String = "", rewardAmount:int = -1):
	Data.add_eternal_ball()
	mediator.ball_count += 1
	mediator.add_ball()


func _on_WatchAd_pressed():
	GPack.show_rewarded_ad()
	watch_ad.visible = false
