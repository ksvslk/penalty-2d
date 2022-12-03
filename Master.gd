extends Node
class_name Master

var scrolling := false
onready var mediator = get_node("Level")
onready var watch_ad = $Level/WatchAd
onready var select_country = $CanvasLayer/OptionsContainer/SelectCountry
onready var loading_screen = $CanvasLayer/OptionsContainer/LoadingScreen
onready var add_ball = $CanvasLayer/OptionsContainer/OptionsList/BallManagement/AddBall
onready var remove_ball = $CanvasLayer/OptionsContainer/OptionsList/BallManagement/RemoveBall
onready var click_sound = $ClickSound
onready var play_games = $CanvasLayer/OptionsContainer/HBoxContainer/PlayGames
onready var bonus = $CanvasLayer/OptionsContainer/HBoxContainer/Bonus
onready var commercial_break = $CanvasLayer/OptionsContainer/CommercialBreak


func _ready():
	loading_screen.visible = true
	if OS.get_name() == "Android":
		GPack.plugin.connect(GPack.s_on_start_loading_saved_game, self, "_show_loading_game")
		GPack.plugin.connect(GPack.s_on_loading_saved_game_complete, self, "_show_loading_game_result")
	if GPack.plugin:
		GPack.plugin.connect(GPack.s_reward_earned, self, "_reward_with_ball")
	else:
		loading_screen.visible = false
		mediator.start_game()


func _on_RemoveBall_pressed():
	var max_balls = Data.get_maximum_ball_count()
	if mediator.ball_count > 1:
		click_sound.play()
		mediator.ball_count -= 1
		mediator.remove_ball()
		if mediator.ball_count < max_balls:
			add_ball.disabled = false
		if mediator.ball_count == 1:
			remove_ball.disabled = true
		if mediator.ball_count > 1:
			remove_ball.disabled = false
			
		

func _on_Continue_gui_input(event):
	if event.is_pressed():
		Data.next_level()


func _on_OptionsContainer_switch_level(nr):
	Data.load_level(nr)


func _on_BonusList_add_ball(count: int = 1):
	Data.add_eternal_ball(count)
	mediator.ball_count += count
	for i in range(0, count):
		mediator.add_ball(true, false)


func _reward_with_ball(rewardType:String = "", rewardAmount:int = -1):
	click_sound.play()
	Data.add_rewarded_ball()
	mediator.ball_count += 1
	mediator.add_ball(true, false)


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


func _on_AddBall_pressed():
	var max_balls = Data.get_maximum_ball_count()
	if mediator.ball_count < max_balls:
		click_sound.play()
		mediator.ball_count += 1
		mediator.add_ball(mediator.ball_count > 3, false)
		if mediator.ball_count == max_balls:
			add_ball.disabled = true
	if mediator.ball_count > 1:
		remove_ball.disabled = false


func _on_FollowTwitter_pressed():
	OS.shell_open("https://twitter.com/IndestGames")


func _on_Level_commercial_break():
	commercial_break.visible = true
