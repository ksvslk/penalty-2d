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
	
	# Deeplink Initialization
	var deeplink = Deeplink.new()
	deeplink.name = "DeeplinkNode"
	add_child(deeplink)
	if not deeplink.deeplink_received.is_connected(_on_deeplink_received):
		deeplink.deeplink_received.connect(_on_deeplink_received)
	deeplink.initialize()

func _on_deeplink_received(url_data: Dictionary) -> void:
	print("DEEPLINK RECEIVED: ", url_data)
	var path = url_data.get("path", "")
	var queries = url_data.get("queries", {})
	
	if "lobby" in path:
		# Hide main menu, show Multiplayer UI
		if has_node("CanvasLayer/OptionsContainer"):
			$CanvasLayer/OptionsContainer.visible = false
		if has_node("CanvasLayer/MultiplayerUI"):
			var mp_ui = $CanvasLayer/MultiplayerUI
			mp_ui.visible = true
			
			# If the link is like https://indest.ee/penalty-2d/lobby?code=ABCD
			if queries.has("code"):
				mp_ui.code_input.text = queries["code"]
				mp_ui._on_join_pressed() # Auto-join!

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
	
	# Use StyleBoxEmpty to remove all outer borders and styling edges
	var empty_style = StyleBoxEmpty.new()
	btn.add_theme_stylebox_override("normal", empty_style)
	btn.add_theme_stylebox_override("hover", empty_style)
	btn.add_theme_stylebox_override("pressed", empty_style)
	btn.add_theme_stylebox_override("focus", empty_style)
	
	# Override text colors (Vibrant gold/orange text)
	btn.add_theme_color_override("font_color", Color(0.9, 0.65, 0.0, 1.0))
	btn.add_theme_color_override("font_hover_color", Color(1.0, 0.8, 0.2, 1.0))
	btn.add_theme_color_override("font_pressed_color", Color(0.7, 0.45, 0.0, 1.0))
	
	# Add clean text drop shadow
	btn.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.85))
	btn.add_theme_constant_override("shadow_offset_x", 4)
	btn.add_theme_constant_override("shadow_offset_y", 4)
	btn.add_theme_constant_override("shadow_outline_size", 6)
	
	# Match the PlayGames button theme styles but make it stand out
	play_games = $CanvasLayer/OptionsContainer/HBoxContainer/PlayGames
	if play_games:
		btn.add_theme_font_override("font", play_games.get_theme_font("font"))
		var base_size = play_games.get_theme_font_size("font_size")
		btn.add_theme_font_size_override("font_size", base_size + 8) # Increase font size by 8
	else:
		btn.add_theme_font_size_override("font_size", 40)
	
	btn.pressed.connect(func(): mp_ui.visible = true)
	
	# Add to container
	var container = $CanvasLayer/OptionsContainer/HBoxContainer
	container.add_child(btn)
	container.move_child(btn, 0)
	
	# Connect Network
	if has_node("/root/Network"):
		var net = get_node_or_null("/root/Network")
		net.game_started.connect(_on_multiplayer_game_started)

var current_round_index := 1
var current_turn_in_round := 1

var host_round_wins := 0
var client_round_wins := 0

var host_round_goals := 0
var client_round_goals := 0

func _on_multiplayer_game_started():
	if loading_screen: loading_screen.visible = false
	$CanvasLayer/OptionsContainer.visible = false
	
	current_round_index = 1
	current_turn_in_round = 1
	host_round_wins = 0
	client_round_wins = 0
	host_round_goals = 0
	client_round_goals = 0
	
	# Silence original arena securely exactly once on both Host and Client
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
	
	if Network.is_host:
		rpc_sync_settings.rpc(Network.match_total_rounds, Network.round_time_limit, Network.round_ball_count)
		start_multiplayer_round()

func start_multiplayer_round():
	var original_level = get_node("OriginalLevel_Disabled")
	
	# Scour and destroy native leftover round arena smoothly
	var old_mp = get_node_or_null("Level")
	if old_mp:
		old_mp.name = "Level_Deleted" # Instantly sever name collision!
		old_mp.queue_free()
		
	# Determine rotating Network Parity (Round 1 Turn 1: Host is Striker, Turn 2: Client is Striker)
	# Turn 1: Host is STRIKER, Client is GOALKEEPER
	# Turn 2: Host is GOALKEEPER, Client is STRIKER
	if current_turn_in_round == 1:
		if Network.is_host:
			Network.my_role_this_round = Network.PlayerRole.STRIKER
		else:
			Network.my_role_this_round = Network.PlayerRole.GOALKEEPER
	else:
		if Network.is_host:
			Network.my_role_this_round = Network.PlayerRole.GOALKEEPER
		else:
			Network.my_role_this_round = Network.PlayerRole.STRIKER
	
	# Clean up leftover physics junk securely from disconnected prior single-player states exactly
	var _bc = original_level.get_node_or_null("BallsContainer")
	if _bc:
		for child in _bc.get_children():
			_bc.remove_child(child)
			child.queue_free()
	
	# Clone node tree cleanly and accurately
	var mp_level = original_level.duplicate()
	mp_level.name = "Level" # Retain core name so NodePaths internally succeed exactly between peers
	
	var bg = mp_level.get_node_or_null("Background")
	if bg: bg.texture = load("res://art/grass_euro.png")
	
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
	
	# Do NOT swap ball scripts here. mp_manager's add_ball overrides handle it seamlessly!
	# Pre-existing balls will be natively deleted by the map loader.
	
	add_child(mp_level)
	
	# Assign explicit Network Node Authorities after node enters tree
	var goalkeeper_id = 0
	if current_turn_in_round == 1:
		goalkeeper_id = Network.connected_peer_id if Network.is_host else multiplayer.get_unique_id()
	else:
		goalkeeper_id = multiplayer.get_unique_id() if Network.is_host else Network.connected_peer_id
		
	goalie.set_multiplayer_authority(goalkeeper_id)
	
	mp_level.start_multiplayer_match()

@rpc("any_peer", "call_remote", "reliable")
func rpc_sync_settings(total_rounds: int, time_limit: int, ball_count: int):
	Network.match_total_rounds = total_rounds
	Network.round_time_limit = time_limit
	Network.round_ball_count = ball_count
	print("Synced settings: total_rounds=", total_rounds, ", time_limit=", time_limit, ", ball_count=", ball_count)
	
	if not Network.is_host:
		start_multiplayer_round()

@rpc("any_peer", "call_remote", "reliable")
func rpc_end_turn_and_swap(h_goals: int, c_goals: int):
	local_end_turn_and_swap(h_goals, c_goals)

@rpc("any_peer", "call_remote", "reliable")
func rpc_end_round(winner_id: int, h_wins: int, c_wins: int):
	local_end_round(winner_id, h_wins, c_wins)

@rpc("any_peer", "call_remote", "reliable")
func rpc_end_match(winner_id: int, h_wins: int, c_wins: int):
	local_end_match(winner_id, h_wins, c_wins)

func host_transition_to_turn_2(h_goals: int, c_goals: int):
	if not Network.is_host: return
	host_round_goals = h_goals
	rpc_end_turn_and_swap.rpc(h_goals, c_goals)
	local_end_turn_and_swap(h_goals, c_goals)

func local_end_turn_and_swap(h_goals: int, c_goals: int):
	host_round_goals = h_goals
	client_round_goals = c_goals
	
	var mp_level = get_node_or_null("Level")
	if mp_level:
		mp_level.round_is_active = false
		if mp_level.has_node("Message"):
			mp_level.get_node("Message").fade_out_text("TURN 1 FINISHED!\nROLES SWAPPING...")
			
	get_tree().create_timer(3.0).timeout.connect(func():
		current_turn_in_round = 2
		start_multiplayer_round()
	)

func host_transition_to_next_round(h_goals: int, c_goals: int):
	if not Network.is_host: return
	client_round_goals = c_goals
	
	var winner_id = 0
	if host_round_goals > client_round_goals:
		host_round_wins += 1
		winner_id = 1
	elif client_round_goals > host_round_goals:
		client_round_wins += 1
		winner_id = Network.connected_peer_id
	else:
		winner_id = 0 # Draw
		
	if current_round_index >= Network.match_total_rounds:
		var match_winner_id = 0
		if host_round_wins > client_round_wins:
			match_winner_id = 1
		elif client_round_wins > host_round_wins:
			match_winner_id = Network.connected_peer_id
		else:
			match_winner_id = 0 # Draw
			
		rpc_end_match.rpc(match_winner_id, host_round_wins, client_round_wins)
		local_end_match(match_winner_id, host_round_wins, client_round_wins)
	else:
		rpc_end_round.rpc(winner_id, host_round_wins, client_round_wins)
		local_end_round(winner_id, host_round_wins, client_round_wins)

func local_end_round(winner_id: int, h_wins: int, c_wins: int):
	host_round_wins = h_wins
	client_round_wins = c_wins
	
	var mp_level = get_node_or_null("Level")
	if mp_level:
		mp_level.round_is_active = false
		
		var winner_text = ""
		if winner_id == multiplayer.get_unique_id():
			winner_text = "YOU WIN THE ROUND!"
		elif winner_id == 0:
			winner_text = "ROUND DRAWN!"
		else:
			winner_text = "OPPONENT WINS ROUND!"
			
		if mp_level.has_node("Message"):
			mp_level.get_node("Message").fade_out_text(winner_text)
			
	get_tree().create_timer(3.0).timeout.connect(func():
		current_round_index += 1
		current_turn_in_round = 1
		start_multiplayer_round()
	)

func local_end_match(winner_id: int, h_wins: int, c_wins: int):
	host_round_wins = h_wins
	client_round_wins = c_wins
	
	var mp_level = get_node_or_null("Level")
	if mp_level:
		mp_level.round_is_active = false
		
		var win_text = ""
		if winner_id == multiplayer.get_unique_id():
			win_text = "VICTORY!\nYOU ARE THE VETERAN STRIKER!"
			if mp_level.get("celebrate") != null:
				mp_level.celebrate.play()
			mp_level.emit_signal("level_passed")
		elif winner_id == 0:
			win_text = "MATCH DRAWN!\nWELL PLAYED!"
		else:
			win_text = "SERIES LOST!\nBETTER LUCK NEXT MATCH..."
			
		if mp_level.has_node("Message"):
			mp_level.get_node("Message").fade_out_text(win_text)
			
	get_tree().create_timer(5.0).timeout.connect(func():
		if Network.multiplayer.has_multiplayer_peer():
			Network.multiplayer.multiplayer_peer.close()
		Network.cancel_matchmaking()
		get_tree().call_deferred("reload_current_scene")
	)


	
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
