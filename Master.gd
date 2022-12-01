extends Node
class_name Master

var scrolling := false
onready var mediator = get_node("Level")
onready var watch_ad = $Level/WatchAd
onready var saving_game = $CanvasLayer/SavingGame
onready var select_country = $CanvasLayer/OptionsContainer/SelectCountry
onready var loading_screen = $CanvasLayer/OptionsContainer/LoadingScreen


func _ready():
	loading_screen.visible = true
	if OS.get_name() == "Android":
		GPack.plugin.connect(GPack.s_on_start_saving_game, self, "_show_saving_game")
		GPack.plugin.connect(GPack.s_on_saving_game_complete, self, "_show_saving_game_result")
		GPack.plugin.connect(GPack.s_on_start_loading_saved_game, self, "_show_loading_game")
		GPack.plugin.connect(GPack.s_on_loading_saved_game_complete, self, "_show_loading_game_result")
	if GPack.plugin:
		GPack.plugin.connect(GPack.s_reward_earned, self, "_reward_with_ball")
	else:
		loading_screen.visible = false
		mediator.start_game()


func _on_RemoveBall_pressed():
	if mediator.ball_count > 1:
		mediator.ball_count -= 1
		mediator.remove_ball()
		

func _on_Continue_gui_input(event):
	if event.is_pressed():
		Data.next_level()


func _on_OptionsContainer_switch_level(nr):
	Data.load_level(nr)


func _on_BonusList_add_ball(count: int = 1):
	Data.add_eternal_ball(count)
	mediator.ball_count += count
	for i in range(0, count):
		mediator.add_ball(true)


func _reward_with_ball(rewardType:String = "", rewardAmount:int = -1):
	Data.add_rewarded_ball()
	mediator.ball_count += 1
	mediator.add_ball(true)


func _on_WatchAd_pressed():
	GPack.show_rewarded_ad()
	watch_ad.visible = false


func _on_BonusList_add_2_balls_disable_ads():
	if not Data.is_two_balls_purchased():
		Data.set_two_balls_purchased(true)
		Data.set_intermediate_ads(false)
		_on_BonusList_add_ball(2)


func _on_BonusList_disable_intermediate_ads():
	if Data.is_intermediate_ads_enabled():
		Data.set_intermediate_ads(false)


func _show_saving_game():
	saving_game.text = "Saving game..."


func _show_saving_game_result(result: bool):
	if result:
		saving_game.modulate = Color.green
		saving_game.text = "Successfully saved game!"
	else:
		saving_game.modulate = Color.red
		saving_game.text = "Something went wrong while saving game... :("


func _show_loading_game():
	loading_screen.visible = true


func _show_loading_game_result(game_data: Dictionary, result: bool):
	if result:
		Data.load_game(game_data)
		print("Successfully loaded a game!")
	else:
		print("Something went wrong when loading game... :(")
	loading_screen.visible = false
	mediator.start_game()


func _on_SelectCountry_team_selection_done():
	if GPack.plugin:
		GPack.load_game()

