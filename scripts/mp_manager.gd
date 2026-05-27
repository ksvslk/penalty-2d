extends "res://scripts/level.gd"

var is_pvp = true

var local_player_name = ""
var local_player_flag = ""
var opponent_player_name = ""
var opponent_player_flag = ""

var hud_canvas: CanvasLayer

var left_name_label: RichTextLabel
var left_total_label: Label
var left_icon_rect: TextureRect
var left_score_label: Label

var right_name_label: Label
var right_total_label: Label
var right_icon_rect: TextureRect
var right_score_label: Label

var round_label: Label
var timer_label: Label

var top_overlay_vbox: VBoxContainer
var top_overlay_flag: TextureRect
var top_overlay_name: Label

var bottom_overlay_vbox: VBoxContainer
var bottom_overlay_flag: TextureRect
var bottom_overlay_name: Label

func _add_tutorial():
	pass # Silence tutorial completely in Multiplayer Mode

func _remove_all_balls():
	var balls_container = get_node_or_null("BallsContainer")
	if balls_container:
		for b in balls_container.get_children():
			balls_container.remove_child(b)
			b.queue_free()
	balls.clear()

func start_multiplayer_match():
	# Hijack the standard start_game loop to inject our custom MP setup
	round_is_active = false
	restart.visible = false
	continue_button.visible = false
	
	# Start native map sequence
	start_game()

func _ready():
	if not Network.player_disconnected.is_connected(_on_network_player_disconnected):
		Network.player_disconnected.connect(_on_network_player_disconnected)
	_setup_player_huds()
	_setup_pitch_overlays()

func _on_network_player_disconnected(_id):
	round_is_active = false
	if message: message.fade_out_text("OPPONENT LEFT!")
	get_tree().create_timer(3.0).timeout.connect(func():
		if Network.multiplayer.has_multiplayer_peer():
			Network.multiplayer.multiplayer_peer.close()
		Network.cancel_matchmaking()
		get_tree().call_deferred("reload_current_scene")
	)

func _update_level_info(info: Dictionary):
	if get_node_or_null("Trophy"):
		remove_child(get_node_or_null("Trophy"))
	
	round_is_active = false
	time.timer.stop()
	restart.visible = false
	continue_button.visible = false
	
	# Set Goalkeeper difficulty/speed from level info
	goal_keeper.speed = info[C.DIFFICULTY]
	
	# Override with multiplayer host settings and re-instantiate the correct ball count!
	ball_count = Network.round_ball_count
	bonus_balls = 0
	_add_all_balls()
	
	# Broadcast and local sync of player info (nickname/flag)
	rpc_sync_player_info.rpc(Network.player_name, Data.get_player_team())
	rpc_sync_player_flag.rpc(Network.my_role_this_round == Network.PlayerRole.STRIKER, Data.get_player_team())
	
	# Override UI Text!
	if highest.get_parent().has_node("HighestLabel"):
		highest.get_parent().get_node("HighestLabel").text = "OPPONENT:"
	else:
		var label4 = highest.get_node_or_null("Label4")
		if label4: label4.text = "OPPONENT:"
		
	var s_label = score.get_node_or_null("Label3")
	if s_label: s_label.text = "YOU:"
	
	_spawn_in_game_menu()

	highest.text = "0"
	var target_goals = (Network.round_ball_count / 2) + 1
	target_score.text = "GOALS TO WIN: " + str(target_goals)
	
	var m = get_node_or_null("/root/Master")
	var round_p = 1
	if m: round_p = m.current_round_index # Accurately read literal current round value natively!
	
	if Network.my_role_this_round == Network.PlayerRole.STRIKER:
		message.fade_out_text("ROUND " + str(round_p))
		for b in balls: b.set_multiplayer_authority(multiplayer.get_unique_id())
		goal_keeper.set_multiplayer_authority(Network.connected_peer_id)
	else:
		message.fade_out_text("ROUND " + str(round_p))
		for b in balls: b.set_multiplayer_authority(Network.connected_peer_id)
		goal_keeper.set_multiplayer_authority(multiplayer.get_unique_id())
		
	# Graphically and stylishly emphasize the user's role interaction zone!
	_spawn_role_style_indicator()

func _spawn_in_game_menu():
	var canvas = CanvasLayer.new()
	canvas.layer = 90
	add_child(canvas)
	
	var root = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(root)
	
	var quit_btn = Button.new()
	quit_btn.text = "QUIT"
	quit_btn.add_theme_font_size_override("font_size", 32)
	quit_btn.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	quit_btn.grow_vertical = Control.GROW_DIRECTION_BEGIN
	
	# Accurately anchor deeply and compactly exclusively inside the native black bar physics void organically!
	quit_btn.offset_left = 250
	quit_btn.offset_right = -250
	quit_btn.offset_bottom = -C.get_bottom_safe_margin() - 70
	quit_btn.offset_top = -C.get_bottom_safe_margin() - 160
	quit_btn.custom_minimum_size = Vector2(0, 90)
	
	var qs = StyleBoxFlat.new()
	qs.bg_color = Color(0.2, 0.05, 0.05, 0.8) # Deep Red
	qs.set_corner_radius_all(15) # Add slight rounding natively
	quit_btn.add_theme_stylebox_override("normal", qs)
	quit_btn.add_theme_stylebox_override("hover", qs)
	quit_btn.add_theme_stylebox_override("pressed", qs)
	
	# Construct fully native aesthetic dialog box geometrically identically matched to game UI!
	var confirm_layer = ColorRect.new()
	confirm_layer.color = Color(0, 0, 0, 0.95)
	confirm_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	confirm_layer.hide() 
	root.add_child(confirm_layer)
	
	var c_label = Label.new()
	c_label.text = "ABANDON MATCH?"
	c_label.add_theme_font_size_override("font_size", 64)
	c_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	c_label.set_anchors_preset(Control.PRESET_CENTER)
	c_label.position.y -= 100
	c_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	confirm_layer.add_child(c_label)
	
	var c_hbox = HBoxContainer.new()
	c_hbox.set_anchors_preset(Control.PRESET_CENTER)
	c_hbox.position.y += 50
	c_hbox.add_theme_constant_override("separation", 30)
	c_hbox.grow_horizontal = Control.GROW_DIRECTION_BOTH
	
	var btn_yes = Button.new()
	btn_yes.text = "YES"
	btn_yes.custom_minimum_size = Vector2(250, 100)
	btn_yes.add_theme_font_size_override("font_size", 48)
	var sb_yes = StyleBoxFlat.new()
	sb_yes.bg_color = Color(0.3, 0.0, 0.0, 1.0)
	btn_yes.add_theme_stylebox_override("normal", sb_yes)
	
	btn_yes.pressed.connect(func():
		round_is_active = false
		if Network.multiplayer.has_multiplayer_peer():
			Network.multiplayer.multiplayer_peer.close()
		Network.cancel_matchmaking()
		get_tree().call_deferred("reload_current_scene")
	)
	
	var btn_no = Button.new()
	btn_no.text = "NO"
	btn_no.custom_minimum_size = Vector2(250, 100)
	btn_no.add_theme_font_size_override("font_size", 48)
	var sb_no = StyleBoxFlat.new()
	sb_no.bg_color = Color(0.2, 0.2, 0.2, 1.0)
	btn_no.add_theme_stylebox_override("normal", sb_no)
	
	btn_no.pressed.connect(func():
		confirm_layer.hide()
	)
	
	c_hbox.add_child(btn_yes)
	c_hbox.add_child(btn_no)
	confirm_layer.add_child(c_hbox)

	quit_btn.pressed.connect(func():
		# Capture raw top UI natively
		confirm_layer.show()
	)
	root.add_child(quit_btn)
	
	# Reinstate beautiful purely centralized independent UI Element
	var tracker = Label.new()
	var master_node = get_node_or_null("/root/Master")
	var hw = master_node.host_round_wins if master_node else 0
	var cw = master_node.client_round_wins if master_node else 0
	var my_wins = hw if Network.is_host else cw
	var op_wins = cw if Network.is_host else hw
	
	tracker.text = "SERIES TRACKER\nYOU: " + str(my_wins) + "      OPPONENT: " + str(op_wins)
	tracker.add_theme_font_size_override("font_size", 42) # Faint but large painted text
	tracker.modulate = Color(1.0, 1.0, 1.0, 0.25) # 25% opacity so it looks like painted grass graphics
	tracker.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tracker.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	tracker.grow_horizontal = Control.GROW_DIRECTION_BOTH
	tracker.grow_vertical = Control.GROW_DIRECTION_BOTH
	tracker.custom_minimum_size = Vector2(600, 200)
	tracker.position = Vector2(540, 1150) - Vector2(300, 100)
	tracker.z_index = -1
	add_child(tracker) # Add directly to Level (self) instead of canvas!


func _spawn_role_style_indicator():
	var canvas = CanvasLayer.new()
	canvas.layer = 100
	add_child(canvas)
	
	var overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.0) # Start fully transparent
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(overlay)
	
	var role_title = Label.new()
	role_title.add_theme_font_size_override("font_size", 64)
	role_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	role_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	role_title.set_anchors_preset(Control.PRESET_CENTER)
	role_title.grow_horizontal = Control.GROW_DIRECTION_BOTH
	role_title.grow_vertical = Control.GROW_DIRECTION_BOTH
	role_title.text = "YOU ARE\n" + ("STRIKER!" if Network.my_role_this_round == Network.PlayerRole.STRIKER else "GOALKEEPER!")
	role_title.modulate = Color(1, 1, 1, 0.0) # Start transparent
	canvas.add_child(role_title)

	# Smoothly fade in overlay and text
	var fade_in = create_tween().set_parallel(true)
	fade_in.tween_property(overlay, "color:a", 0.75, 0.4).set_trans(Tween.TRANS_SINE)
	fade_in.tween_property(role_title, "modulate:a", 1.0, 0.4).set_trans(Tween.TRANS_SINE)

	var glow_hand = Sprite2D.new()
	glow_hand.texture = load("res://art/hand.png")
	glow_hand.scale = Vector2(2.5, 2.5) # Prominent "fat finger" sizing
	glow_hand.modulate = Color(1.2, 1.2, 1.5, 0.0) 
	canvas.add_child(glow_hand)
	
	var tween = create_tween().set_loops(2) 
	
	if Network.my_role_this_round == Network.PlayerRole.STRIKER:
		var start_pos = Vector2(540, 2100)
		var end_pos = Vector2(540, 1400)
		glow_hand.position = start_pos
		
		# Exact 1.5 seconds per loop
		tween.tween_property(glow_hand, "modulate:a", 1.0, 0.2)
		tween.tween_property(glow_hand, "position", end_pos, 0.9).set_trans(Tween.TRANS_SINE)
		tween.tween_property(glow_hand, "modulate:a", 0.0, 0.3)
		tween.tween_property(glow_hand, "position", start_pos, 0.1) 
	else:
		var start_pos = Vector2(200, 180)
		var end_pos = Vector2(880, 180)
		glow_hand.position = start_pos
		
		# Exact 1.5 seconds per loop
		tween.tween_property(glow_hand, "modulate:a", 1.0, 0.1)
		tween.tween_property(glow_hand, "position", end_pos, 0.6).set_trans(Tween.TRANS_SINE)
		tween.tween_property(glow_hand, "position", start_pos, 0.6).set_trans(Tween.TRANS_SINE)
		tween.tween_property(glow_hand, "modulate:a", 0.0, 0.2)
		
	tween.finished.connect(func():
		# Smoothly fade out overlay and text before activating round
		var fade_out = create_tween().set_parallel(true)
		fade_out.tween_property(overlay, "color:a", 0.0, 0.4).set_trans(Tween.TRANS_SINE)
		fade_out.tween_property(role_title, "modulate:a", 0.0, 0.4).set_trans(Tween.TRANS_SINE)
		fade_out.finished.connect(func():
			canvas.queue_free()
			round_start_actions()
			round_is_active = true
		)
	)

func add_ball(eternal_ball = false, adding_all_balls = false, pos = $BallPositions.get_children()[0]):
	# Override base add_ball completely to avoid calling set_script on active node which causes reset/position issues
	var new_ball = ball_scene.instantiate()
	new_ball.name = "PvpBall_" + str(balls.size() + 1) # Guarantee identical RPC node paths!
	new_ball.set_script(load("res://scripts/mp_ball.gd"))
	
	new_ball.mediator = self
	new_ball.scale = new_ball.scale / 2
	new_ball.set_flag(Data.get_player_team())
	new_ball.global_position = pos.global_position
	
	if eternal_ball:
		new_ball.activate_bonus_patch()
		if not adding_all_balls:
			new_ball.global_position = $BallPositions/SpecialPosition.global_position - Vector2(0, 400)
			
	$BallsContainer.add_child(new_ball)
	balls.push_front(new_ball)
	goal_keeper.balls = balls
	
	new_ball.init_multiplayer()
	new_ball.set_multiplayer_authority(1) # Host securely owns ALL predictive ball physics initially

# Override single player logic
var mp_time_remaining = 60.0
var local_host_score = 0
var local_client_score = 0

func _process(delta):
	if round_is_active:
		if Network.is_host:
			mp_time_remaining -= delta
			if mp_time_remaining < 0: mp_time_remaining = 0
			rpc("sync_mp_time", mp_time_remaining)
			
			if mp_time_remaining <= 0:
				print("Round timed out.")
				round_is_active = false
				_end_turn_delayed()
			else:
				# Check if all balls are finished
				var all_finished = true
				if balls.is_empty():
					all_finished = false
				else:
					for b in balls:
						if is_instance_valid(b):
							var b_shot = b.get("was_shot") == true
							var b_finished = b_shot and (b.sleeping or b.global_position.y < 150 or not b.is_in_bounds())
							if not b_finished:
								all_finished = false
								break
						else:
							pass
							
				if all_finished:
					print("All balls finished.")
					round_is_active = false
					_end_turn_delayed()
				
		if timer_label:
			timer_label.text = str(int(mp_time_remaining))

@rpc("any_peer", "call_local", "reliable")
func rpc_sync_player_flag(is_striker: bool, flag_id: String):
	if is_striker:
		for b in balls: b.set_flag(flag_id)
	else:
		var tex = load("res://art/flag/" + flag_id + ".png")
		if tex: goal_keeper.set_flag(tex)

@rpc("unreliable", "call_remote", "any_peer")
func sync_mp_time(t: float):
	mp_time_remaining = t

func round_start_actions():
	emit_signal("start_level")
	if time and time.timer:
		(time.timer as Timer).stop() # Terminate native UI timer perfectly
	whistle_sound.play()
	# The tween inside _spawn_role_style_indicator will explicitly trigger `round_is_active = true`!
	new_high_score_announced = false
	mp_time_remaining = Network.round_time_limit
	
func _on_Goal_body_shape_entered(_body_rid, body, _body_shape_index, _local_shape_index):
	if round_is_active:
		goal_counter += 1
		
		# Visually mirror single-player juiciness identically without disrupting network state!
		var bonus = time.start_time <= BONUS_TIME if time else false
		if goal_indicator:
			goal_indicator.goal(bonus)
		if bonus:
			vibrate()
			if bonus_goal_sound: bonus_goal_sound.play()
		else:
			if goal_sound: goal_sound.play()
			
		# Voice cue feedback for local player when they are the Striker and score
		if Network.my_role_this_round == Network.PlayerRole.STRIKER:
			var is_fast = false
			if body and body.get("current_y_velocity") != null:
				var trail_limit = body.get("trail_speed_limit") if body.get("trail_speed_limit") != null else -5500
				is_fast = (body.current_y_velocity < trail_limit)
				
			var clip = "res://sound/voice_nice_shot.wav" if is_fast else "res://sound/voice_goal.wav"
			_play_voice_over(clip)
			
		_check_mp_score()

func _check_mp_score():
	# ONLY evaluate mathematical progression on the server to prevent race conditions
	if Network.is_host:
		var _master = get_node_or_null("/root/Master")
		var turn = _master.current_turn_in_round if _master else 1
		if turn == 1:
			local_host_score += 1
		else:
			local_client_score += 1
			
		rpc("sync_mp_score", local_host_score, local_client_score)
		_update_mp_score_labels()
			
func _end_turn_delayed():
	# Graceful pause before resetting state
	get_tree().create_timer(3.0).timeout.connect(func():
		var _master = get_node_or_null("/root/Master")
		if _master and _master.has_method("host_transition_to_turn_2") and _master.has_method("host_transition_to_next_round"):
			var turn = _master.current_turn_in_round
			if turn == 1:
				_master.host_transition_to_turn_2(local_host_score, local_client_score)
			else:
				_master.host_transition_to_next_round(local_host_score, local_client_score)
	)

@rpc("reliable", "call_local")
func rpc_round_ended(winner_id: int):
	round_is_active = false
	
	if winner_id == multiplayer.get_unique_id():
		message.fade_out_text("VICTORY!")
		if celebrate: celebrate.play()
		emit_signal("level_passed")
	else:
		message.fade_out_text("OPPONENT WINS ROUND!")
			
@rpc("reliable", "call_remote", "any_peer")
func sync_mp_score(h_score: int, c_score: int):
	local_host_score = h_score
	local_client_score = c_score
	_update_mp_score_labels()
	
	var target_goals = (Network.round_ball_count / 2) + 1
	if local_host_score >= target_goals or local_client_score >= target_goals:
		if target_score: target_score.modulate = Color.GREEN_YELLOW

func _update_mp_score_labels():
	_update_hud_display()

func _setup_player_huds():
	# Hide singleplayer Display and TargetScore
	var display_node = get_node_or_null("Display")
	if display_node:
		display_node.visible = false
	if target_score:
		target_score.visible = false
		
	hud_canvas = CanvasLayer.new()
	hud_canvas.layer = 50
	add_child(hud_canvas)
	
	var hud_root = Control.new()
	hud_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	hud_canvas.add_child(hud_root)
	
	# Horizontal HUD Container
	var hbox = HBoxContainer.new()
	hbox.position = Vector2(40, 1100)
	hbox.size = Vector2(1000, 180)
	hbox.custom_minimum_size = Vector2(1000, 180)
	hbox.add_theme_constant_override("separation", 20)
	hud_root.add_child(hbox)
	
	# Style for Panels
	var p_style = StyleBoxFlat.new()
	p_style.bg_color = Color(0.0, 0.0, 0.0, 1.0) # Solid black
	p_style.border_width_left = 2
	p_style.border_width_right = 2
	p_style.border_width_top = 2
	p_style.border_width_bottom = 2
	p_style.border_color = Color(0.12, 0.53, 0.15, 1.0) # Theme green
	p_style.corner_radius_top_left = 8
	p_style.corner_radius_top_right = 8
	p_style.corner_radius_bottom_left = 8
	p_style.corner_radius_bottom_right = 8
	
	# 1. Left Panel (Local Player)
	var left_panel = PanelContainer.new()
	left_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_panel.custom_minimum_size = Vector2(320, 180)
	left_panel.add_theme_stylebox_override("panel", p_style)
	hbox.add_child(left_panel)
	
	var left_content = Control.new()
	left_panel.add_child(left_content)
	
	left_icon_rect = TextureRect.new()
	left_icon_rect.texture = load("res://art/goalkeeper_gloves.png")
	left_icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	left_icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	left_icon_rect.size = Vector2(100, 100)
	left_icon_rect.position = Vector2(110, 40)
	left_content.add_child(left_icon_rect)
	
	left_score_label = Label.new()
	left_score_label.text = "0"
	left_score_label.add_theme_font_size_override("font_size", 72)
	left_score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	left_score_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	left_score_label.size = Vector2(320, 180)
	left_score_label.position = Vector2(0, -10)
	left_content.add_child(left_score_label)
	
	left_total_label = Label.new()
	left_total_label.text = "TOTAL: 0"
	left_total_label.add_theme_font_size_override("font_size", 28)
	left_total_label.position = Vector2(20, 135)
	left_content.add_child(left_total_label)
	
	left_name_label = RichTextLabel.new()
	left_name_label.bbcode_enabled = true
	left_name_label.text = local_player_name + " [color=#55ff55](YOU)[/color]"
	left_name_label.add_theme_font_size_override("normal_font_size", 32)
	left_name_label.custom_minimum_size = Vector2(320, 50)
	left_name_label.size = Vector2(320, 50)
	left_name_label.position = Vector2(40, 1045)
	left_name_label.scroll_active = false
	hud_root.add_child(left_name_label)
	
	# 2. Center Panel (Status/Clock)
	var center_panel = PanelContainer.new()
	center_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center_panel.custom_minimum_size = Vector2(320, 180)
	center_panel.add_theme_stylebox_override("panel", p_style)
	hbox.add_child(center_panel)
	
	var center_content = Control.new()
	center_panel.add_child(center_content)
	
	timer_label = Label.new()
	timer_label.text = "60"
	timer_label.add_theme_font_size_override("font_size", 96)
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	timer_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	timer_label.size = Vector2(320, 180)
	timer_label.position = Vector2(0, -5)
	timer_label.modulate = Color.GREEN
	center_content.add_child(timer_label)
	
	# CenterContainer to perfectly center the round panel horizontally at y = 1038
	var round_container = CenterContainer.new()
	round_container.custom_minimum_size = Vector2(1080, 50)
	round_container.size = Vector2(1080, 50)
	round_container.position = Vector2(0, 1038)
	hud_root.add_child(round_container)
	
	var round_border_panel = PanelContainer.new()
	var border_style = StyleBoxFlat.new()
	border_style.bg_color = Color(0, 0, 0, 0.8)
	border_style.border_width_left = 2
	border_style.border_width_right = 2
	border_style.border_width_top = 2
	border_style.border_width_bottom = 2
	border_style.border_color = Color(0.85, 0.85, 0.0, 1.0) # Yellow border
	border_style.corner_radius_top_left = 4
	border_style.corner_radius_top_right = 4
	border_style.corner_radius_bottom_left = 4
	border_style.corner_radius_bottom_right = 4
	border_style.content_margin_left = 15
	border_style.content_margin_right = 15
	border_style.content_margin_top = 5
	border_style.content_margin_bottom = 5
	round_border_panel.add_theme_stylebox_override("panel", border_style)
	
	round_label = Label.new()
	round_label.text = "ROUND 1 of 3"
	round_label.add_theme_font_size_override("font_size", 24)
	round_border_panel.add_child(round_label)
	round_container.add_child(round_border_panel)
	
	# 3. Right Panel (Opponent Player)
	var right_panel = PanelContainer.new()
	right_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_panel.custom_minimum_size = Vector2(320, 180)
	right_panel.add_theme_stylebox_override("panel", p_style)
	hbox.add_child(right_panel)
	
	var right_content = Control.new()
	right_panel.add_child(right_content)
	
	right_icon_rect = TextureRect.new()
	right_icon_rect.texture = load("res://art/goalkeeper_gloves.png")
	right_icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	right_icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	right_icon_rect.size = Vector2(100, 100)
	right_icon_rect.position = Vector2(110, 40)
	right_content.add_child(right_icon_rect)
	
	right_score_label = Label.new()
	right_score_label.text = "0"
	right_score_label.add_theme_font_size_override("font_size", 72)
	right_score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	right_score_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	right_score_label.size = Vector2(320, 180)
	right_score_label.position = Vector2(0, -10)
	right_content.add_child(right_score_label)
	
	right_total_label = Label.new()
	right_total_label.text = "TOTAL: 0"
	right_total_label.add_theme_font_size_override("font_size", 28)
	right_total_label.position = Vector2(180, 135)
	right_content.add_child(right_total_label)
	
	right_name_label = Label.new()
	right_name_label.text = opponent_player_name
	right_name_label.add_theme_font_size_override("font_size", 32)
	right_name_label.position = Vector2(720, 1045)
	hud_root.add_child(right_name_label)

func _setup_pitch_overlays():
	# Top overlay (Goalkeeper side)
	top_overlay_vbox = VBoxContainer.new()
	top_overlay_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	top_overlay_vbox.custom_minimum_size = Vector2(500, 300)
	top_overlay_vbox.size = Vector2(500, 300)
	top_overlay_vbox.position = Vector2(540 - 250, 550 - 150)
	top_overlay_vbox.z_index = -1
	top_overlay_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(top_overlay_vbox)
	
	top_overlay_flag = TextureRect.new()
	top_overlay_flag.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	top_overlay_flag.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	top_overlay_flag.custom_minimum_size = Vector2(160, 100)
	top_overlay_flag.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	top_overlay_flag.modulate = Color(1.0, 1.0, 1.0, 0.15)
	top_overlay_vbox.add_child(top_overlay_flag)
	
	top_overlay_name = Label.new()
	top_overlay_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	top_overlay_name.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	top_overlay_name.add_theme_font_size_override("font_size", 48)
	top_overlay_name.modulate = Color(1.0, 1.0, 1.0, 0.25)
	top_overlay_vbox.add_child(top_overlay_name)
	
	# Bottom overlay (Striker side)
	bottom_overlay_vbox = VBoxContainer.new()
	bottom_overlay_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	bottom_overlay_vbox.custom_minimum_size = Vector2(500, 300)
	bottom_overlay_vbox.size = Vector2(500, 300)
	bottom_overlay_vbox.position = Vector2(540 - 250, 1700 - 150)
	bottom_overlay_vbox.z_index = -1
	bottom_overlay_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bottom_overlay_vbox)
	
	bottom_overlay_flag = TextureRect.new()
	bottom_overlay_flag.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bottom_overlay_flag.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	bottom_overlay_flag.custom_minimum_size = Vector2(160, 100)
	bottom_overlay_flag.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	bottom_overlay_flag.modulate = Color(1.0, 1.0, 1.0, 0.15)
	bottom_overlay_vbox.add_child(bottom_overlay_flag)
	
	bottom_overlay_name = Label.new()
	bottom_overlay_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bottom_overlay_name.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	bottom_overlay_name.add_theme_font_size_override("font_size", 48)
	bottom_overlay_name.modulate = Color(1.0, 1.0, 1.0, 0.25)
	bottom_overlay_vbox.add_child(bottom_overlay_name)

func _update_hud_display():
	if not left_name_label or not right_name_label: return
	
	var master_node = get_node_or_null("/root/Master")
	var r_wins_host = master_node.host_round_wins if master_node else 0
	var r_wins_client = master_node.client_round_wins if master_node else 0
	var my_r_wins = r_wins_host if Network.is_host else r_wins_client
	var op_r_wins = r_wins_client if Network.is_host else r_wins_host
	
	left_total_label.text = "TOTAL: " + str(my_r_wins)
	right_total_label.text = "TOTAL: " + str(op_r_wins)
	
	var r_p = master_node.current_round_index if master_node else 1
	round_label.text = "ROUND " + str(r_p) + " of " + str(Network.match_total_rounds)
	
	left_name_label.text = local_player_name + " [color=#55ff55](YOU)[/color]"
	right_name_label.text = opponent_player_name
	
	if Network.my_role_this_round == Network.PlayerRole.STRIKER:
		left_icon_rect.visible = false
		left_score_label.visible = true
		left_score_label.text = str(local_host_score if Network.is_host else local_client_score)
		
		right_icon_rect.visible = true
		right_score_label.visible = false
		
		# Field overlays: Local player is Striker (Bottom), Opponent is Goalkeeper (Top)
		if top_overlay_name and top_overlay_flag:
			top_overlay_name.text = opponent_player_name
			if not opponent_player_flag.is_empty():
				top_overlay_flag.texture = load("res://art/flag/" + opponent_player_flag + ".png")
				top_overlay_flag.show()
			else:
				top_overlay_flag.hide()
		if bottom_overlay_name and bottom_overlay_flag:
			bottom_overlay_name.text = local_player_name + " (YOU)"
			if not local_player_flag.is_empty():
				bottom_overlay_flag.texture = load("res://art/flag/" + local_player_flag + ".png")
				bottom_overlay_flag.show()
			else:
				bottom_overlay_flag.hide()
	else:
		left_icon_rect.visible = true
		left_score_label.visible = false
		
		right_icon_rect.visible = false
		right_score_label.visible = true
		right_score_label.text = str(local_client_score if Network.is_host else local_host_score)
		
		# Field overlays: Local player is Goalkeeper (Top), Opponent is Striker (Bottom)
		if top_overlay_name and top_overlay_flag:
			top_overlay_name.text = local_player_name + " (YOU)"
			if not local_player_flag.is_empty():
				top_overlay_flag.texture = load("res://art/flag/" + local_player_flag + ".png")
				top_overlay_flag.show()
			else:
				top_overlay_flag.hide()
		if bottom_overlay_name and bottom_overlay_flag:
			bottom_overlay_name.text = opponent_player_name
			if not opponent_player_flag.is_empty():
				bottom_overlay_flag.texture = load("res://art/flag/" + opponent_player_flag + ".png")
				bottom_overlay_flag.show()
			else:
				bottom_overlay_flag.hide()

@rpc("any_peer", "call_local", "reliable")
func rpc_sync_player_info(p_name: String, p_flag: String):
	var sender_id = multiplayer.get_remote_sender_id()
	if sender_id == 0: sender_id = multiplayer.get_unique_id()
	
	if sender_id == multiplayer.get_unique_id():
		local_player_name = p_name
		local_player_flag = p_flag
	else:
		opponent_player_name = p_name
		opponent_player_flag = p_flag
		
	_update_hud_display()

# Completely block single player progression hooks!
func _play_fanfares_when_level_passed(time_left = 1337) -> void: pass
func _check_corner_shot(body): pass
func _check_center_shot(body): pass
func _check_first_second_goal_achievement(): pass
func _check_all_goals_achievement(): pass
func _check_champion_achievement(): pass
func _check_high_score(): pass

func _play_voice_over(file_path: String):
	var stream = load(file_path)
	if stream:
		var player = AudioStreamPlayer.new()
		player.stream = stream
		add_child(player)
		player.play()
		player.finished.connect(player.queue_free)
