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


# adb logcat -b all -v color | grep -E 'godot|penalty2d' | grep -E '\bD\b'

func _load_ios_game_data():
	if Engine.has_singleton("ICloud"):
		var singleton = Engine.get_singleton("ICloud")
		var game_data = singleton.get_all_key_values()
		if not game_data.empty():
			Data.load_game(game_data)


func _ready():
	_disable_playing()
	if OS.get_name() == "Android":
		GPack.plugin.connect(GPack.s_on_start_loading_saved_game, self, "_disable_playing")
		GPack.plugin.connect(GPack.s_on_loading_saved_game_complete, self, "_show_loading_game_result")
	if OS.get_name() == "iOS":
		_load_ios_game_data()
		_enable_playing()
	if GPack.plugin:
		GPack.plugin.connect(GPack.s_reward_earned, self, "_reward_with_ball")
	if OS.get_name() == "OSX":
		_enable_playing()
	_print_license()

	
func show_review():
	if OS.get_name() == "Android":
		GPack.plugin.connect(GPack.s_on_start_showing_review, self, "_disable_playing")
		GPack.plugin.connect(GPack.s_on_ending_review, self, "end_review")
		GPack.plugin.askForReview()


func end_review():
	loading_screen.visible = false
	GPack.plugin.disconnect(GPack.s_on_start_showing_review, self, "_disable_playing")
	GPack.plugin.disconnect(GPack.s_on_ending_review, self, "end_review")


func _disable_playing():
	loading_screen.visible = true


func _enable_playing(select_country_flag = false):
	if (select_country and not select_country.visible) or select_country_flag:
		if loading_screen:
			loading_screen.visible = false
		if mediator:
			mediator.start_game()


func _print_license():
	print("Copyright (c) 2007-2022 Juan Linietsky, Ariel Manzur."\
+"Copyright (c) 2014-2022 Godot Engine contributors (cf. AUTHORS.md)."\

+"Permission is hereby granted, free of charge, to any person obtaining a copy"\
+"of this software and associated documentation files (the 'Software'), to deal"\
+"in the Software without restriction, including without limitation the rights"\
+"to use, copy, modify, merge, publish, distribute, sublicense, and/or sell"\
+"copies of the Software, and to permit persons to whom the Software is"\
+"furnished to do so, subject to the following conditions:"\

+"The above copyright notice and this permission notice shall be included in all"\
+"copies or substantial portions of the Software."\

+"THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR"\
+"IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,"\
+"FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE"\
+"AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER"\
+"LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,"\
+"OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE"\
+"SOFTWARE.")


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


func _show_loading_game_result(game_data: Dictionary, result: bool):
	if result:
		Data.load_game(game_data)
		print("Successfully loaded a game!")
	else:
		print("Something went wrong when loading game... :( or first time")
	_enable_playing()


func _on_SelectCountry_team_selection_done():
	if GPack.plugin:
		GPack.load_game()
	if OS.get_name() == "iOS":
		_enable_playing(true)


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

