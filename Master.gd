extends Node
class_name Master

var scrolling := false
@onready var mediator = $Level
@onready var watch_ad = $Level/WatchAd
@onready var select_country = $CanvasLayer/OptionsContainer/SelectCountry
@onready var loading_screen = $CanvasLayer/OptionsContainer/LoadingScreen
@onready var add_ball = $CanvasLayer/OptionsContainer/OptionsList/InnerBox/BallManagement/AddBall
@onready var remove_ball = $CanvasLayer/OptionsContainer/OptionsList/InnerBox/BallManagement/RemoveBall
@onready var click_sound = $ClickSound
@onready var play_games = $CanvasLayer/OptionsContainer/HBoxContainer/PlayGames
@onready var bonus = $CanvasLayer/OptionsContainer/HBoxContainer/Bonus
@onready var commercial_break = $CanvasLayer/OptionsContainer/CommercialBreak


# adb logcat -b all -v color | grep -E 'godot|penalty2d' | grep -E '\bD\b'

func _load_ios_game_data() -> void:
	if Engine.has_singleton("ICloud"):
		var singleton = Engine.get_singleton("ICloud")
		var game_data: Dictionary = singleton.get_all_key_values()
		if not game_data.is_empty():
			Data.load_game(game_data)


func _ready() -> void:
	_disable_playing()
	# Godot 4 signal connection syntax
	if select_country:
		if not select_country.team_selection_done.is_connected(_on_SelectCountry_team_selection_done):
			select_country.team_selection_done.connect(_on_SelectCountry_team_selection_done)
		
	if OS.get_name() == "Android":
		if GPack.plugin:
			GPack.plugin.on_start_loading_saved_game.connect(_disable_playing)
			GPack.plugin.on_loading_saved_game_complete.connect(_show_loading_game_result)
		_enable_playing() # Enable playing by default so game doesn't get stuck!
	if OS.get_name() == "iOS":
		_load_ios_game_data()
		_enable_playing()
	if GPack.plugin:
		GPack.plugin.reward_earned.connect(_reward_with_ball)
	if OS.get_name() == "macOS":
		_enable_playing()
	_print_license()
	_setup_multiplayer_ui()

func _setup_multiplayer_ui():
	# Create UI
	var mp_script = load("res://scripts/multiplayer_ui.gd")
	var mp_ui = mp_script.new()
	mp_ui.visible = false
	mp_ui.name = "MultiplayerUI"
	$CanvasLayer.add_child(mp_ui)
	
	# Create Button
	var btn = Button.new()
	btn.text = "PVP"
	btn.mouse_filter = Control.MOUSE_FILTER_PASS
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.size_flags_stretch_ratio = 0.5
	
	# Match the PlayGames button theme styles
	play_games = $CanvasLayer/OptionsContainer/HBoxContainer/PlayGames
	if play_games:
		btn.add_theme_font_override("font", play_games.get_theme_font("font"))
		btn.add_theme_font_size_override("font_size", play_games.get_theme_font_size("font_size"))
		btn.add_theme_stylebox_override("normal", play_games.get_theme_stylebox("normal"))
		btn.add_theme_stylebox_override("hover", play_games.get_theme_stylebox("hover"))
		btn.add_theme_stylebox_override("pressed", play_games.get_theme_stylebox("pressed"))
	
	btn.pressed.connect(func(): mp_ui.visible = true)
	
	# Add to container
	var container = $CanvasLayer/OptionsContainer/HBoxContainer
	container.add_child(btn)
	container.move_child(btn, 0)
	
	# Connect Network
	if has_node("/root/Network"):
		var net = get_node_or_null("/root/Network")
		net.game_started.connect(_on_multiplayer_game_started)

var mp_rounds_played = 0
var host_match_wins = 0
var client_match_wins = 0

func _on_multiplayer_game_started():
	if loading_screen: loading_screen.visible = false
	$CanvasLayer/OptionsContainer.visible = false
	
	mp_rounds_played = 0
	host_match_wins = 0
	client_match_wins = 0
	
	# Silence original arena securely exactly once
	var original_level = get_node_or_null("Level")
	if original_level:
		original_level.name = "SinglePlayerLevel"
		original_level.hide()
		original_level.set_process(false)
		original_level.set_physics_process(false)
		original_level.process_mode = Node.PROCESS_MODE_DISABLED
		if original_level.has_method("_remove_all_balls"):
			original_level._remove_all_balls()
		original_level.name = "OriginalLevel_Disabled"
		
	start_multiplayer_round()

func start_multiplayer_round():
	mp_rounds_played += 1
	var original_level = get_node("OriginalLevel_Disabled")
	
	# Scour and destroy native leftover round arena smoothly
	var old_mp = get_node_or_null("Level")
	if old_mp:
		old_mp.name = "Level_Deleted" # Instantly sever name collision!
		old_mp.queue_free()
		
	# Determine rotating Network Parity (Host is Striker on Round 1 and Round 3)
	if Network.is_host:
		Network.my_role_this_round = Network.PlayerRole.STRIKER if (mp_rounds_played % 2 != 0) else Network.PlayerRole.GOALKEEPER
	else:
		Network.my_role_this_round = Network.PlayerRole.GOALKEEPER if (mp_rounds_played % 2 != 0) else Network.PlayerRole.STRIKER
	
	# Clone node tree cleanly and accurately
	var mp_level = original_level.duplicate()
	mp_level.name = "Level" # Retain core name so NodePaths internally succeed exactly between peers
	mp_level.show()
	mp_level.modulate = Color.WHITE
	mp_level.process_mode = Node.PROCESS_MODE_INHERIT
	mp_level.set_process(true)
	mp_level.set_physics_process(true)
	mp_level.set_script(load("res://scripts/mp_manager.gd"))
	
	# Pre-emptively swap child scripts BEFORE add_child so Godot triggers _ready natively!
	var goalie = mp_level.get_node("GoalKeeper")
	goalie.set_script(load("res://scripts/mp_goalkeeper.gd"))
	goalie.init_multiplayer()
	
	# Assign explicit Network Node Authorities (Otherwise Host exclusively controls local inputs for both sides!)
	var striker_id = 1
	var goalkeeper_id = multiplayer.get_unique_id() if not Network.is_host else Network.connected_peer_id
	goalie.set_multiplayer_authority(goalkeeper_id)
	
	# Do NOT swap ball scripts here. mp_manager's add_ball overrides handle it seamlessly!
	# Pre-existing balls will be natively deleted by the map loader.
	
	add_child(mp_level)
	
	mp_level.start_multiplayer_match()
		
@rpc("any_peer", "call_remote", "reliable")
func trigger_next_round(round_winner_id: int):
	# Calculate match series wins securely
	if round_winner_id == 1:
		host_match_wins += 1
	elif round_winner_id != 0:
		client_match_wins += 1
		
	if host_match_wins >= 2 or client_match_wins >= 2:
		# Series Decided!
		var _mp_level = get_node_or_null("Level")
		if _mp_level and _mp_level.has_node("Message"):
			var win_text = "HOST WINS MATCH!" if host_match_wins >= 2 else "CLIENT WINS MATCH!"
			if (Network.is_host and host_match_wins >= 2) or (not Network.is_host and client_match_wins >= 2):
				win_text = "YOU WIN THE MATCH!"
			else:
				win_text = "YOU LOST THE MATCH!"
			_mp_level.get_node("Message").fade_out_text(win_text)
	else:
		start_multiplayer_round()


	
func show_review() -> void:
	if OS.get_name() == "Android":
		GPack.plugin.on_start_showing_review.connect(_disable_playing)
		GPack.plugin.on_ending_review.connect(end_review)
		GPack.plugin.askForReview()


func end_review() -> void:
	loading_screen.visible = false
	GPack.plugin.on_start_showing_review.disconnect(_disable_playing)
	GPack.plugin.on_ending_review.disconnect(end_review)


func _disable_playing() -> void:
	loading_screen.visible = true


func _enable_playing(select_country_flag := false) -> void:
	print("_enable_playing")
	if loading_screen:
		loading_screen.visible = false
		
	if (select_country and not select_country.visible) or select_country_flag:
		print("select_country and not select_country.visible) or select_country_flag")
		if mediator:
			print("mediator")
			mediator.start_game()


func _print_license() -> void:
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


func _on_RemoveBall_pressed() -> void:
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


func _on_Continue_gui_input(event: InputEvent) -> void:
	if event.is_pressed():
		Data.next_level()


func _on_OptionsContainer_switch_level(nr: int) -> void:
	Data.load_level(nr)


func _on_BonusList_add_ball(count: int = 1) -> void:
	Data.add_eternal_ball(count)
	mediator.ball_count += count
	for i in range(count):
		mediator.add_ball(true, false)


func _reward_with_ball(_rewardType: String = "", _rewardAmount: int = -1) -> void:
	click_sound.play()
	Data.add_rewarded_ball()
	mediator.ball_count += 1
	mediator.add_ball(true, false)


func _on_WatchAd_pressed() -> void:
	GPack.show_rewarded_ad()
	watch_ad.visible = false


func _on_BonusList_add_2_balls_disable_ads() -> void:
	if not Data.is_two_balls_purchased():
		Data.set_two_balls_purchased(true)
		Data.set_intermediate_ads(false)
		_on_BonusList_add_ball(2)


func _on_BonusList_disable_intermediate_ads() -> void:
	if Data.is_intermediate_ads_enabled():
		Data.set_intermediate_ads(false)


func _show_loading_game_result(game_data: Dictionary, result: int) -> void:
	print("_show_loading_game_result")
	if result == 1:
		Data.load_game(game_data)
		print("Successfully loaded a game!")
	else:
		print("Something went wrong when loading game... :( or first time")
	_enable_playing()


func _on_SelectCountry_team_selection_done() -> void:
	if GPack.plugin:
		GPack.load_game()
	_enable_playing(true)


func _on_AddBall_pressed() -> void:
	var max_balls = Data.get_maximum_ball_count()
	if mediator.ball_count < max_balls:
		click_sound.play()
		mediator.ball_count += 1
		mediator.add_ball(mediator.ball_count > 3, false)
		if mediator.ball_count == max_balls:
			add_ball.disabled = true
	if mediator.ball_count > 1:
		remove_ball.disabled = false


func _on_FollowTwitter_pressed() -> void:
	OS.shell_open("https://twitter.com/IndestGames")


func _on_Level_commercial_break() -> void:
	commercial_break.visible = true


func _on_OptionsContainer_menu_active(value: bool) -> void:
	if value:
		var color = Color("#404040")
		mediator.modulate = color
	else:
		mediator.modulate = Color.WHITE
