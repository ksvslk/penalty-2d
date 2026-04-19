extends "res://scripts/level.gd"

var is_pvp = true

func _add_tutorial():
	pass # Silence tutorial completely in Multiplayer Mode

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

func _on_network_player_disconnected(_id):
	if round_is_active:
		round_is_active = false
		if message: message.fade_out_text("OPPONENT LEFT!")
		get_tree().create_timer(3.0).timeout.connect(func():
			if Network.multiplayer.has_multiplayer_peer():
				Network.multiplayer.multiplayer_peer.close()
			Network.cancel_matchmaking()
			get_tree().call_deferred("reload_current_scene")
		)

func _update_level_info(info: Dictionary):
	super._update_level_info(info)
	
	# Broadcast our dynamically chosen flag symmetrically natively
	rpc("rpc_sync_player_flag", Network.my_role_this_round == Network.PlayerRole.STRIKER, Data.get_player_team())
	
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
	target_score.text = "GOALS TO WIN: 20"
	
	var m = get_node_or_null("/root/Master")
	var round_p = 1
	if m: round_p = m.mp_rounds_played # Accurately read literal current round value natively!
	
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
	var hw = master_node.host_match_wins if master_node else 0
	var cw = master_node.client_match_wins if master_node else 0
	var my_wins = hw if Network.is_host else cw
	var op_wins = cw if Network.is_host else hw
	
	tracker.text = "SERIES TRACKER\nYOU: " + str(my_wins) + "      OPPONENT: " + str(op_wins)
	tracker.add_theme_font_size_override("font_size", 26)
	tracker.modulate = Color(1.0, 1.0, 1.0, 0.8)
	tracker.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tracker.set_anchors_preset(Control.PRESET_TOP_WIDE)
	tracker.position.y = 150 # Absolute safe zone underneath the header
	root.add_child(tracker)


func _spawn_role_style_indicator():
	var canvas = CanvasLayer.new()
	canvas.layer = 100
	add_child(canvas)
	
	var overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.75)
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
	role_title.modulate = Color(1, 1, 1, 1) # Explicitly pure white
	canvas.add_child(role_title)

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
		canvas.queue_free()
		round_is_active = true
	)

func add_ball(eternal_ball = false, adding_all_balls = false, pos = $BallPositions.get_children()[0]):
	super.add_ball(eternal_ball, adding_all_balls, pos)
	var new_ball = balls[0] # Single-Player script actually uses push_front, not append!
	new_ball.name = "PvpBall_" + str(balls.size()) # Guarantee identical RPC node paths!
	new_ball.set_script(load("res://scripts/mp_ball.gd")) # Safely inject physics AFTER add_child completes native hierarchy logic
	new_ball.init_multiplayer() # Restore @onready variables wiped by set_script!
	new_ball.mediator = self # Godot natively wipes references when replacing a script, so rebuild the link!
	new_ball.set_multiplayer_authority(1) # Host securely owns ALL predictive ball physics
	# Player flags are initialized dynamically natively during _update_level_info via our new RPC Sync struct!

# Override single player logic
var mp_time_remaining = 60.0 # Standard 60 second match
var local_host_score = 0
var local_client_score = 0

func _process(delta):
	if round_is_active:
		if Network.is_host:
			mp_time_remaining -= delta
			if mp_time_remaining < 0: mp_time_remaining = 0
			rpc("sync_mp_time", mp_time_remaining)
			
			if mp_time_remaining <= 0:
				print("Round timed out, Goalkeeper wins automatically.")
				if Network.my_role_this_round == Network.PlayerRole.GOALKEEPER:
					message.fade_out_text("SAVED!")
				else:
					message.fade_out_text("TIME UP!")
				round_is_active = false
				var goalkeeper_id = multiplayer.get_unique_id() if Network.my_role_this_round == Network.PlayerRole.GOALKEEPER else Network.connected_peer_id
				_end_round_delayed(goalkeeper_id)
				
		if time:
			# Update Visual Clock using pure network-synced struct
			time.text = str(int(mp_time_remaining))

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
	mp_time_remaining = 60.0
	score.text = str(0)
	target_score.modulate = Color.YELLOW
	
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
			
		_check_mp_score()

func _check_mp_score():
	# ONLY evaluate mathematical progression on the server to prevent race conditions
	if Network.is_host:
		local_host_score += 1
		rpc("sync_mp_score", local_host_score, local_client_score)
		_update_mp_score_labels()
		
		# MATCH TO 20 (First to 20 wins the round physically)
		if local_host_score >= 20:
			round_is_active = false
			if message:
				if Network.my_role_this_round == Network.PlayerRole.STRIKER:
					message.fade_out_text("GOAL!")
				else:
					message.fade_out_text("OPPONENT SCORED!")
			print("Goal reached Target Y, Striker wins round.")
			var striker_id = multiplayer.get_unique_id() if Network.my_role_this_round == Network.PlayerRole.STRIKER else Network.connected_peer_id
			_end_round_delayed(striker_id)
			
func _end_round_delayed(winning_peer_id: int):
	# Graceful pause before resetting state
	get_tree().create_timer(3.0).timeout.connect(func():
		var _master = get_parent()
		if _master and _master.has_method("trigger_next_round"):
			_master.rpc("trigger_next_round", winning_peer_id) # Fire network packet FIRST!
			_master.trigger_next_round(winning_peer_id) # Process local destruction SECOND!
	)
			
@rpc("reliable", "call_remote", "any_peer")
func sync_mp_score(h_score: int, c_score: int):
	local_host_score = h_score
	local_client_score = c_score
	_update_mp_score_labels()
	
	if local_host_score >= 20 or local_client_score >= 20:
		if target_score: target_score.modulate = Color.GREEN_YELLOW

func _update_mp_score_labels():
	if Network.my_role_this_round == Network.PlayerRole.STRIKER:
		score.text = str(local_host_score)
		highest.text = str(local_client_score)
	else:
		score.text = str(local_client_score)
		highest.text = str(local_host_score)

# Completely block single player progression hooks!
func _play_fanfares_when_level_passed(time_left = 1337) -> void: pass
func _check_corner_shot(body): pass
func _check_center_shot(body): pass
func _check_first_second_goal_achievement(): pass
func _check_all_goals_achievement(): pass
func _check_champion_achievement(): pass
func _check_high_score(): pass
