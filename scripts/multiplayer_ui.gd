extends Control

var quick_match_btn: Button
var host_btn: Button
var join_btn: Button
var code_input: LineEdit
var status_label: Label
var back_btn: Button
var copy_btn: Button
var main_container: VBoxContainer
var osk_offset_active = false

var cancel_btn: Button
var accept_btn: Button
var decline_btn: Button
var confirmation_container: HBoxContainer

func _ready():
	# Setup UI
	anchors_preset = Control.PRESET_FULL_RECT
	
	var bg = ColorRect.new()
	bg.color = Color(0.0, 0.0, 0.0, 1.0)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	
	main_container = VBoxContainer.new()
	main_container.set_anchors_preset(Control.PRESET_CENTER)
	main_container.grow_horizontal = Control.GROW_DIRECTION_BOTH
	main_container.grow_vertical = Control.GROW_DIRECTION_BOTH
	main_container.alignment = BoxContainer.ALIGNMENT_CENTER
	main_container.add_theme_constant_override("separation", 40)
	add_child(main_container)
	
	var title = Label.new()
	title.text = "MULTIPLAYER"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 48)
	main_container.add_child(title)
	
	status_label = Label.new()
	status_label.text = "Select Mode"
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.add_theme_font_size_override("font_size", 32)
	main_container.add_child(status_label)
	
	quick_match_btn = _create_button("QUICK MATCH")
	quick_match_btn.pressed.connect(_on_quick_match_pressed)
	# Slight green tint for the primary button natively
	var qm_style = quick_match_btn.get_theme_stylebox("normal").duplicate()
	qm_style.bg_color = Color(0.1, 0.3, 0.1, 0.96)
	quick_match_btn.add_theme_stylebox_override("normal", qm_style)
	quick_match_btn.add_theme_stylebox_override("hover", qm_style)
	main_container.add_child(quick_match_btn)
	
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 40)
	main_container.add_child(spacer)
	
	var divider = HBoxContainer.new()
	divider.alignment = BoxContainer.ALIGNMENT_CENTER
	divider.add_theme_constant_override("separation", 20)
	main_container.add_child(divider)
	
	var sep1 = HSeparator.new()
	sep1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sep1.custom_minimum_size = Vector2(250, 0)
	sep1.modulate = Color(0.4, 0.4, 0.4, 0.5)
	divider.add_child(sep1)
	
	var friend_label = Label.new()
	friend_label.text = "OR PLAY WITH FRIEND"
	friend_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	friend_label.add_theme_font_size_override("font_size", 28)
	friend_label.modulate = Color(0.6, 0.6, 0.6, 1.0)
	divider.add_child(friend_label)
	
	var sep2 = HSeparator.new()
	sep2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sep2.custom_minimum_size = Vector2(250, 0)
	sep2.modulate = Color(0.4, 0.4, 0.4, 0.5)
	divider.add_child(sep2)
	
	host_btn = _create_button("CREATE ROOM")
	host_btn.pressed.connect(_on_host_pressed)
	main_container.add_child(host_btn)
	
	var join_container = HBoxContainer.new()
	join_container.alignment = BoxContainer.ALIGNMENT_CENTER
	main_container.add_child(join_container)
	
	code_input = LineEdit.new()
	code_input.placeholder_text = "ENTER CODE"
	code_input.custom_minimum_size = Vector2(320, 140)
	code_input.add_theme_font_size_override("font_size", 32)
	code_input.alignment = HORIZONTAL_ALIGNMENT_CENTER
	code_input.focus_entered.connect(_on_osk_focus_entered)
	code_input.focus_exited.connect(_on_osk_focus_exited)
	join_container.add_child(code_input)
	
	join_btn = _create_button("JOIN")
	join_btn.custom_minimum_size = Vector2(550, 140)
	join_btn.pressed.connect(_on_join_pressed)
	join_container.add_child(join_btn)
	
	copy_btn = _create_button("COPY CODE")
	copy_btn.visible = false
	copy_btn.pressed.connect(_on_copy_pressed)
	main_container.add_child(copy_btn)
	
	cancel_btn = _create_button("CANCEL WAITING")
	cancel_btn.visible = false
	cancel_btn.pressed.connect(_on_cancel_pressed)
	# Give cancel a slight red tint
	var c_style = cancel_btn.get_theme_stylebox("normal").duplicate()
	c_style.bg_color = Color(0.4, 0.1, 0.1, 0.96)
	cancel_btn.add_theme_stylebox_override("normal", c_style)
	cancel_btn.add_theme_stylebox_override("hover", c_style)
	main_container.add_child(cancel_btn)

	confirmation_container = HBoxContainer.new()
	confirmation_container.alignment = BoxContainer.ALIGNMENT_CENTER
	confirmation_container.add_theme_constant_override("separation", 20)
	confirmation_container.visible = false
	main_container.add_child(confirmation_container)
	
	accept_btn = _create_button("ACCEPT")
	accept_btn.custom_minimum_size = Vector2(440, 140)
	var a_style = accept_btn.get_theme_stylebox("normal").duplicate()
	a_style.bg_color = Color(0.1, 0.4, 0.1, 0.96)
	accept_btn.add_theme_stylebox_override("normal", a_style)
	accept_btn.add_theme_stylebox_override("hover", a_style)
	accept_btn.pressed.connect(_on_accept_pressed)
	confirmation_container.add_child(accept_btn)
	
	decline_btn = _create_button("DECLINE")
	decline_btn.custom_minimum_size = Vector2(440, 140)
	var d_style = decline_btn.get_theme_stylebox("normal").duplicate()
	d_style.bg_color = Color(0.4, 0.1, 0.1, 0.96)
	decline_btn.add_theme_stylebox_override("normal", d_style)
	decline_btn.add_theme_stylebox_override("hover", d_style)
	decline_btn.pressed.connect(_on_decline_pressed)
	confirmation_container.add_child(decline_btn)

	back_btn = _create_button("BACK")
	back_btn.pressed.connect(_on_back_pressed)
	back_btn.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	back_btn.offset_left = -450
	back_btn.offset_right = 450
	back_btn.offset_bottom = -150
	back_btn.offset_top = -290
	add_child(back_btn)
	
	# Connect Network Signals
	if has_node("/root/Network"):
		var network = get_node_or_null("/root/Network")
		network.lobby_created.connect(_on_lobby_created)
		network.joined_lobby.connect(_on_joined_lobby)
		network.game_error.connect(_on_game_error)
		network.game_started.connect(_on_game_started)
		network.joined_queue.connect(_on_queue_joined)
		network.match_found.connect(_on_match_found)
		network.match_cancelled.connect(_on_match_cancelled)
		
func _on_osk_focus_entered():
	if not osk_offset_active:
		osk_offset_active = true
		var t = create_tween()
		t.tween_property(main_container, "position:y", main_container.position.y - 350, 0.2).set_trans(Tween.TRANS_SINE)

func _on_osk_focus_exited():
	if osk_offset_active:
		osk_offset_active = false
		var t = create_tween()
		t.tween_property(main_container, "position:y", main_container.position.y + 350, 0.2).set_trans(Tween.TRANS_SINE)

func _create_button(text: String) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(900, 140)
	btn.add_theme_font_size_override("font_size", 48)
	
	var premium_btn = StyleBoxFlat.new()
	premium_btn.bg_color = Color(0.01, 0.01, 0.01, 0.96)
	premium_btn.corner_radius_top_left = 15
	premium_btn.corner_radius_top_right = 15
	premium_btn.corner_radius_bottom_left = 15
	premium_btn.corner_radius_bottom_right = 15
	premium_btn.content_margin_left = 40
	premium_btn.content_margin_right = 40
	premium_btn.content_margin_top = 20
	premium_btn.content_margin_bottom = 20
	
	btn.add_theme_stylebox_override("normal", premium_btn)
	btn.add_theme_stylebox_override("hover", premium_btn)
	btn.add_theme_stylebox_override("pressed", premium_btn)
	
	return btn

func _on_quick_match_pressed():
	status_label.text = "Connecting..."
	Network.connect_to_signaling_server()
	await get_tree().create_timer(0.5).timeout
	Network.quick_match()
	
	host_btn.visible = false
	join_btn.visible = false
	quick_match_btn.visible = false
	code_input.visible = false
	cancel_btn.visible = true

func _on_host_pressed():
	status_label.text = "Connecting to signaling..."
	Network.connect_to_signaling_server()
	await get_tree().create_timer(0.5).timeout
	Network.create_game()

func _on_join_pressed():
	if code_input.text.is_empty():
		status_label.text = "Please enter a code"
		return
		
	status_label.text = "Connecting..."
	Network.connect_to_signaling_server()
	await get_tree().create_timer(0.5).timeout
	Network.join_game(code_input.text.strip_edges().to_upper())
	
	host_btn.visible = false
	join_btn.visible = false
	quick_match_btn.visible = false
	code_input.visible = false
	cancel_btn.visible = true

func _on_cancel_pressed():
	Network.cancel_matchmaking()
	_reset_to_start()

func _on_accept_pressed():
	Network.accept_match()
	status_label.text = "WAITING FOR OTHER PLAYER..."
	accept_btn.disabled = true
	decline_btn.disabled = true

func _on_decline_pressed():
	Network.decline_match()
	_reset_to_start()

func _reset_to_start():
	status_label.text = "Select Mode"
	host_btn.visible = true
	join_btn.visible = true
	quick_match_btn.visible = true
	code_input.visible = true
	copy_btn.visible = false
	cancel_btn.visible = false
	confirmation_container.visible = false
	accept_btn.disabled = false
	decline_btn.disabled = false

func _on_queue_joined():
	status_label.text = "SEARCHING FOR PLAYERS..."

func _on_lobby_created(code):
	status_label.text = "WAITING FOR FRIEND...\nCODE: " + str(code)
	code_input.text = str(code)
	code_input.editable = false
	host_btn.visible = false
	join_btn.visible = false
	quick_match_btn.visible = false
	copy_btn.visible = true
	cancel_btn.visible = true

func _on_match_found(role):
	status_label.text = "MATCH FOUND!\nYOU WILL BE " + role.to_upper() + "\nACCEPT?"
	copy_btn.visible = false
	cancel_btn.visible = false
	confirmation_container.visible = true
	
func _on_match_cancelled():
	status_label.text = "Match Cancelled."
	await get_tree().create_timer(1.2).timeout
	_reset_to_start()

func _on_joined_lobby():
	status_label.text = "MATCH ACCEPTED! Connecting WebRTC..."
	confirmation_container.visible = false
	cancel_btn.visible = false

func _on_game_error(msg):
	status_label.text = "Error: " + str(msg)
	host_btn.visible = true
	join_btn.visible = true
	quick_match_btn.visible = true
	code_input.visible = true
	copy_btn.visible = false

func _on_game_started():
	status_label.text = "STARTING GAME!"
	await get_tree().create_timer(1.0).timeout
	visible = false
	# Get Level and start multiplayer
	# This should be handled by a signal in Master.gd or Level.gd

func _on_back_pressed():
	visible = false
	var m = get_node_or_null("/root/Master")
	if m:
		var opts = m.get_node_or_null("CanvasLayer/OptionsContainer")
		if opts:
			opts.show()
			
	# Natively disconnect gracefully to clear sockets
	if Network.multiplayer.has_multiplayer_peer():
		Network.multiplayer.multiplayer_peer.close()

func _on_copy_pressed():
	DisplayServer.clipboard_set(code_input.text)
	status_label.text += "\n(Copied!)"
