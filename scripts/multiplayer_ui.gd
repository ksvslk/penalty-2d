extends Control

var quick_match_btn: Button
var host_btn: Button
var join_btn: Button
var code_input: LineEdit
var status_label: Label
var back_btn: Button
var copy_btn: Button
var main_container: VBoxContainer
var popup_overlay: ColorRect
var popup_title: Label
var popup_input: LineEdit
var active_target_input: LineEdit

var cancel_btn: Button
var accept_btn: Button
var decline_btn: Button
var confirmation_container: HBoxContainer

var nickname_input: LineEdit
var host_settings_container: VBoxContainer

var host_panel: PanelContainer
var join_panel: PanelContainer
var scroll_container: ScrollContainer

var rounds_slider: HSlider
var time_slider: HSlider
var balls_slider: HSlider
var rounds_label: Label
var time_label: Label
var balls_label: Label

func _ready():
	# Setup UI
	anchors_preset = Control.PRESET_FULL_RECT
	
	var bg = ColorRect.new()
	bg.color = Color(0.0, 0.0, 0.0, 1.0)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	
	scroll_container = ScrollContainer.new()
	scroll_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll_container.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll_container.follow_focus = true
	add_child(scroll_container)
	
	var margin_container = MarginContainer.new()
	margin_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin_container.add_theme_constant_override("margin_left", 90)
	margin_container.add_theme_constant_override("margin_right", 90)
	margin_container.add_theme_constant_override("margin_top", 100)
	margin_container.add_theme_constant_override("margin_bottom", 100)
	scroll_container.add_child(margin_container)
	
	main_container = VBoxContainer.new()
	main_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_container.alignment = BoxContainer.ALIGNMENT_CENTER
	main_container.add_theme_constant_override("separation", 30)
	margin_container.add_child(main_container)
	
	var title = Label.new()
	title.text = "MULTIPLAYER"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 48)
	main_container.add_child(title)
	
	nickname_input = LineEdit.new()
	nickname_input.placeholder_text = "ENTER NICKNAME"
	nickname_input.text = Network.player_name
	nickname_input.custom_minimum_size = Vector2(900, 140)
	nickname_input.add_theme_font_size_override("font_size", 42)
	nickname_input.alignment = HORIZONTAL_ALIGNMENT_CENTER
	nickname_input.virtual_keyboard_enabled = false
	nickname_input.focus_entered.connect(func(): _on_osk_focus_entered(nickname_input))
	nickname_input.text_changed.connect(_on_nickname_changed)
	main_container.add_child(nickname_input)
	
	status_label = Label.new()
	status_label.text = "Select Mode"
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.add_theme_font_size_override("font_size", 36)
	main_container.add_child(status_label)
	
	quick_match_btn = _create_button("QUICK MATCH")
	quick_match_btn.pressed.connect(_on_quick_match_pressed)
	# Slight green tint for the primary button natively
	var qm_style = quick_match_btn.get_theme_stylebox("normal").duplicate()
	qm_style.bg_color = Color(0.1, 0.3, 0.1, 0.96)
	quick_match_btn.add_theme_stylebox_override("normal", qm_style)
	quick_match_btn.add_theme_stylebox_override("hover", qm_style)
	main_container.add_child(quick_match_btn)
	
	# Premium styled card background for the Host and Join areas
	var card_style = StyleBoxFlat.new()
	card_style.bg_color = Color(0.06, 0.06, 0.06, 0.95)
	card_style.border_width_left = 3
	card_style.border_width_right = 3
	card_style.border_width_top = 3
	card_style.border_width_bottom = 3
	card_style.border_color = Color(0.12, 0.53, 0.15, 0.5) # Themed green border with opacity
	card_style.corner_radius_top_left = 15
	card_style.corner_radius_top_right = 15
	card_style.corner_radius_bottom_left = 15
	card_style.corner_radius_bottom_right = 15
	card_style.content_margin_left = 30
	card_style.content_margin_right = 30
	card_style.content_margin_top = 30
	card_style.content_margin_bottom = 30

	# 1. HOST PANEL (Create match + settings)
	host_panel = PanelContainer.new()
	host_panel.add_theme_stylebox_override("panel", card_style)
	main_container.add_child(host_panel)
	
	var host_vbox = VBoxContainer.new()
	host_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	host_vbox.add_theme_constant_override("separation", 25)
	host_panel.add_child(host_vbox)
	
	var settings_title = Label.new()
	settings_title.text = "HOST MATCH SETTINGS"
	settings_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	settings_title.add_theme_font_size_override("font_size", 40)
	settings_title.modulate = Color(0.8, 0.8, 0.8, 1.0)
	host_vbox.add_child(settings_title)
	
	var slider_track_style = StyleBoxFlat.new()
	slider_track_style.bg_color = Color(0.04, 0.04, 0.04, 1.0) # Pitch black
	slider_track_style.border_width_left = 2
	slider_track_style.border_width_right = 2
	slider_track_style.border_width_top = 2
	slider_track_style.border_width_bottom = 2
	slider_track_style.border_color = Color(0.12, 0.53, 0.15, 0.25) # Subtle green tint border
	slider_track_style.expand_margin_top = 6
	slider_track_style.expand_margin_bottom = 6
	slider_track_style.corner_radius_top_left = 6
	slider_track_style.corner_radius_top_right = 6
	slider_track_style.corner_radius_bottom_left = 6
	slider_track_style.corner_radius_bottom_right = 6
	
	var grabber_area_style = StyleBoxFlat.new()
	grabber_area_style.bg_color = Color(0.12, 0.53, 0.15, 0.8) # Solid themed green
	grabber_area_style.expand_margin_top = 6
	grabber_area_style.expand_margin_bottom = 6
	grabber_area_style.corner_radius_top_left = 6
	grabber_area_style.corner_radius_bottom_left = 6

	# Load, scale, and programmatically color the grabber knob to a futuristic neon circle
	var raw_grabber = load("res://art/circular5128x128.png")
	var grabber_img = raw_grabber.get_image()
	grabber_img.resize(54, 54, Image.INTERPOLATE_LANCZOS)
	
	var center = Vector2(27, 27)
	var neon_green = Color(0.15, 0.7, 0.2, 1.0)
	var dark_green = Color(0.04, 0.2, 0.05, 1.0)
	
	for y in range(grabber_img.get_height()):
		for x in range(grabber_img.get_width()):
			var dist = Vector2(x, y).distance_to(center)
			if dist <= 27.0:
				var pixel = grabber_img.get_pixel(x, y)
				if pixel.a > 0.1:
					if dist < 18.0:
						grabber_img.set_pixel(x, y, Color(dark_green.r, dark_green.g, dark_green.b, pixel.a))
					else:
						grabber_img.set_pixel(x, y, Color(neon_green.r, neon_green.g, neon_green.b, pixel.a))
	var grabber_tex = ImageTexture.create_from_image(grabber_img)

	# 1. Rounds Slider Block
	var rounds_block = VBoxContainer.new()
	rounds_block.add_theme_constant_override("separation", 10)
	host_vbox.add_child(rounds_block)
	
	rounds_label = Label.new()
	rounds_label.text = "Rounds: " + str(Network.match_total_rounds)
	rounds_label.add_theme_font_size_override("font_size", 32)
	rounds_label.modulate = Color(0.7, 0.7, 0.7, 1.0)
	rounds_block.add_child(rounds_label)
	
	rounds_slider = HSlider.new()
	rounds_slider.min_value = 1
	rounds_slider.max_value = 10
	rounds_slider.step = 1
	rounds_slider.value = Network.match_total_rounds
	rounds_slider.custom_minimum_size = Vector2(0, 80)
	rounds_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rounds_slider.add_theme_stylebox_override("slider", slider_track_style)
	rounds_slider.add_theme_stylebox_override("grabber_area", grabber_area_style)
	rounds_slider.add_theme_stylebox_override("grabber_area_highlight", grabber_area_style)
	rounds_slider.add_theme_icon_override("grabber", grabber_tex)
	rounds_slider.add_theme_icon_override("grabber_highlight", grabber_tex)
	rounds_block.add_child(rounds_slider)
	
	rounds_slider.value_changed.connect(func(val):
		Network.match_total_rounds = int(val)
		rounds_label.text = "Rounds: " + str(int(val))
	)

	# 2. Time Slider Block
	var time_block = VBoxContainer.new()
	time_block.add_theme_constant_override("separation", 10)
	host_vbox.add_child(time_block)
	
	time_label = Label.new()
	time_label.text = "Time: " + str(Network.round_time_limit) + "s"
	time_label.add_theme_font_size_override("font_size", 32)
	time_label.modulate = Color(0.7, 0.7, 0.7, 1.0)
	time_block.add_child(time_label)
	
	time_slider = HSlider.new()
	time_slider.min_value = 30
	time_slider.max_value = 120
	time_slider.step = 15 # 30s, 45s, 60s, 75s, 90s, 105s, 120s
	time_slider.value = Network.round_time_limit
	time_slider.custom_minimum_size = Vector2(0, 80)
	time_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	time_slider.add_theme_stylebox_override("slider", slider_track_style)
	time_slider.add_theme_stylebox_override("grabber_area", grabber_area_style)
	time_slider.add_theme_stylebox_override("grabber_area_highlight", grabber_area_style)
	time_slider.add_theme_icon_override("grabber", grabber_tex)
	time_slider.add_theme_icon_override("grabber_highlight", grabber_tex)
	time_block.add_child(time_slider)
	
	time_slider.value_changed.connect(func(val):
		Network.round_time_limit = int(val)
		time_label.text = "Time: " + str(int(val)) + "s"
	)

	# 3. Balls Slider Block
	var balls_block = VBoxContainer.new()
	balls_block.add_theme_constant_override("separation", 10)
	host_vbox.add_child(balls_block)
	
	balls_label = Label.new()
	balls_label.text = "Balls: " + str(Network.round_ball_count)
	balls_label.add_theme_font_size_override("font_size", 32)
	balls_label.modulate = Color(0.7, 0.7, 0.7, 1.0)
	balls_block.add_child(balls_label)
	
	balls_slider = HSlider.new()
	balls_slider.min_value = 1
	balls_slider.max_value = 10
	balls_slider.step = 1
	balls_slider.value = Network.round_ball_count
	balls_slider.custom_minimum_size = Vector2(0, 80)
	balls_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	balls_slider.add_theme_stylebox_override("slider", slider_track_style)
	balls_slider.add_theme_stylebox_override("grabber_area", grabber_area_style)
	balls_slider.add_theme_stylebox_override("grabber_area_highlight", grabber_area_style)
	balls_slider.add_theme_icon_override("grabber", grabber_tex)
	balls_slider.add_theme_icon_override("grabber_highlight", grabber_tex)
	balls_block.add_child(balls_slider)
	
	balls_slider.value_changed.connect(func(val):
		Network.round_ball_count = int(val)
		balls_label.text = "Balls: " + str(int(val))
	)
	
	host_btn = _create_button("CREATE ROOM")
	host_btn.pressed.connect(_on_host_pressed)
	host_vbox.add_child(host_btn)
	
	# 2. JOIN PANEL (Join friend's room)
	join_panel = PanelContainer.new()
	join_panel.add_theme_stylebox_override("panel", card_style)
	main_container.add_child(join_panel)
	
	var join_vbox = VBoxContainer.new()
	join_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	join_vbox.add_theme_constant_override("separation", 20)
	join_panel.add_child(join_vbox)
	
	var join_title = Label.new()
	join_title.text = "JOIN MATCH"
	join_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	join_title.add_theme_font_size_override("font_size", 40)
	join_title.modulate = Color(0.8, 0.8, 0.8, 1.0)
	join_vbox.add_child(join_title)
	
	var join_container = HBoxContainer.new()
	join_container.alignment = BoxContainer.ALIGNMENT_CENTER
	join_vbox.add_child(join_container)
	
	code_input = LineEdit.new()
	code_input.placeholder_text = "ENTER CODE"
	code_input.custom_minimum_size = Vector2(320, 140)
	code_input.add_theme_font_size_override("font_size", 36)
	code_input.alignment = HORIZONTAL_ALIGNMENT_CENTER
	code_input.virtual_keyboard_enabled = false
	code_input.focus_entered.connect(func(): _on_osk_focus_entered(code_input))
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
	main_container.add_child(back_btn)
	
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
		
	# Ensure the UI page is reset whenever it is made visible
	visibility_changed.connect(func():
		if visible:
			_reset_to_start()
	)
	
	# Create Custom Popup overlay
	popup_overlay = ColorRect.new()
	popup_overlay.color = Color(0, 0, 0, 0.75)
	popup_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	popup_overlay.visible = false
	add_child(popup_overlay)
	
	# Close popup when tapping the overlay background
	popup_overlay.gui_input.connect(func(event):
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_hide_popup(false)
	)
	
	var popup_card_style = StyleBoxFlat.new()
	popup_card_style.bg_color = Color(0.06, 0.06, 0.06, 0.98)
	popup_card_style.border_width_left = 3
	popup_card_style.border_width_right = 3
	popup_card_style.border_width_top = 3
	popup_card_style.border_width_bottom = 3
	popup_card_style.border_color = Color(0.12, 0.53, 0.15, 0.8) # Green border
	popup_card_style.corner_radius_top_left = 15
	popup_card_style.corner_radius_top_right = 15
	popup_card_style.corner_radius_bottom_left = 15
	popup_card_style.corner_radius_bottom_right = 15
	popup_card_style.content_margin_left = 40
	popup_card_style.content_margin_right = 40
	popup_card_style.content_margin_top = 30
	popup_card_style.content_margin_bottom = 30
	
	var popup_panel = PanelContainer.new()
	popup_panel.add_theme_stylebox_override("panel", popup_card_style)
	popup_panel.custom_minimum_size = Vector2(800, 320)
	
	popup_overlay.add_child(popup_panel)
	popup_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	popup_panel.grow_vertical = Control.GROW_DIRECTION_END
	popup_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP, Control.PRESET_MODE_KEEP_SIZE, 180)
	
	var popup_vbox = VBoxContainer.new()
	popup_vbox.add_theme_constant_override("separation", 20)
	popup_panel.add_child(popup_vbox)
	
	popup_title = Label.new()
	popup_title.text = "ENTER TEXT"
	popup_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	popup_title.add_theme_font_size_override("font_size", 32)
	popup_title.modulate = Color(0.8, 0.8, 0.8, 1.0)
	popup_vbox.add_child(popup_title)
	
	popup_input = LineEdit.new()
	popup_input.placeholder_text = "ENTER TEXT"
	popup_input.custom_minimum_size = Vector2(700, 110)
	popup_input.add_theme_font_size_override("font_size", 34)
	popup_input.alignment = HORIZONTAL_ALIGNMENT_CENTER
	popup_input.text_submitted.connect(func(text):
		_hide_popup(true)
	)
	popup_vbox.add_child(popup_input)
	
	var popup_buttons = HBoxContainer.new()
	popup_buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	popup_buttons.add_theme_constant_override("separation", 30)
	popup_vbox.add_child(popup_buttons)
	
	var popup_cancel = _create_button("CANCEL")
	popup_cancel.custom_minimum_size = Vector2(330, 110)
	popup_cancel.add_theme_font_size_override("font_size", 32)
	var cancel_style = StyleBoxFlat.new()
	cancel_style.bg_color = Color(0.4, 0.1, 0.1, 0.96)
	cancel_style.corner_radius_top_left = 15
	cancel_style.corner_radius_top_right = 15
	cancel_style.corner_radius_bottom_left = 15
	cancel_style.corner_radius_bottom_right = 15
	cancel_style.content_margin_left = 40
	cancel_style.content_margin_right = 40
	cancel_style.content_margin_top = 20
	cancel_style.content_margin_bottom = 20
	popup_cancel.add_theme_stylebox_override("normal", cancel_style)
	popup_cancel.add_theme_stylebox_override("hover", cancel_style)
	popup_cancel.add_theme_stylebox_override("pressed", cancel_style)
	popup_cancel.pressed.connect(func():
		_hide_popup(false)
	)
	popup_buttons.add_child(popup_cancel)
	
	var popup_confirm = _create_button("OK")
	popup_confirm.custom_minimum_size = Vector2(330, 110)
	popup_confirm.add_theme_font_size_override("font_size", 32)
	var ok_style = StyleBoxFlat.new()
	ok_style.bg_color = Color(0.1, 0.4, 0.1, 0.96)
	ok_style.corner_radius_top_left = 15
	ok_style.corner_radius_top_right = 15
	ok_style.corner_radius_bottom_left = 15
	ok_style.corner_radius_bottom_right = 15
	ok_style.content_margin_left = 40
	ok_style.content_margin_right = 40
	ok_style.content_margin_top = 20
	ok_style.content_margin_bottom = 20
	popup_confirm.add_theme_stylebox_override("normal", ok_style)
	popup_confirm.add_theme_stylebox_override("hover", ok_style)
	popup_confirm.add_theme_stylebox_override("pressed", ok_style)
	popup_confirm.pressed.connect(func():
		_hide_popup(true)
	)
	popup_buttons.add_child(popup_confirm)
		
func _on_osk_focus_entered(target: LineEdit):
	if not target or not target.editable:
		return
	call_deferred("_handle_osk_focus", target)

func _handle_osk_focus(target: LineEdit):
	if not is_instance_valid(target):
		return
	target.release_focus()
	
	if target == nickname_input:
		_show_popup(nickname_input, "ENTER NICKNAME")
	elif target == code_input:
		_show_popup(code_input, "ENTER ROOM CODE")

func _show_popup(target: LineEdit, title_text: String):
	if not is_instance_valid(popup_overlay) or not is_instance_valid(popup_title) or not is_instance_valid(popup_input):
		return
	active_target_input = target
	popup_title.text = title_text
	popup_input.text = target.text
	popup_overlay.visible = true
	popup_input.call_deferred("grab_focus")
	popup_input.call_deferred("select_all")

func _hide_popup(confirm: bool):
	if confirm and active_target_input:
		active_target_input.text = popup_input.text
		if active_target_input == nickname_input:
			_on_nickname_changed(popup_input.text)
			
	if is_instance_valid(popup_overlay):
		popup_overlay.visible = false
	if active_target_input:
		active_target_input.release_focus()
	active_target_input = null

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
	if nickname_input: nickname_input.release_focus()
	status_label.text = "Connecting..."
	Network.connect_to_signaling_server()
	await get_tree().create_timer(0.5).timeout
	Network.quick_match()
	
	host_panel.visible = false
	join_panel.visible = false
	quick_match_btn.visible = false
	cancel_btn.visible = true
	nickname_input.visible = false

func _on_host_pressed():
	if nickname_input: nickname_input.release_focus()
	status_label.text = "Connecting to signaling..."
	Network.connect_to_signaling_server()
	
	host_panel.visible = false
	join_panel.visible = false
	quick_match_btn.visible = false
	cancel_btn.visible = true
	nickname_input.visible = false
	
	await get_tree().create_timer(0.5).timeout
	Network.create_game()

func _on_join_pressed():
	if code_input: code_input.release_focus()
	if nickname_input: nickname_input.release_focus()
	if code_input.text.is_empty():
		status_label.text = "Please enter a code"
		return
		
	status_label.text = "Connecting..."
	Network.connect_to_signaling_server()
	
	host_panel.visible = false
	join_panel.visible = false
	quick_match_btn.visible = false
	cancel_btn.visible = true
	nickname_input.visible = false
	
	await get_tree().create_timer(0.5).timeout
	Network.join_game(code_input.text.strip_edges().to_upper())

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
	host_panel.visible = true
	join_panel.visible = true
	quick_match_btn.visible = true
	code_input.editable = true
	copy_btn.visible = false
	cancel_btn.visible = false
	confirmation_container.visible = false
	accept_btn.disabled = false
	decline_btn.disabled = false
	nickname_input.visible = true
	
	scroll_container.scroll_vertical = 0
	_hide_popup(false)
	
	if rounds_slider:
		rounds_slider.value = Network.match_total_rounds
		rounds_label.text = "Rounds: " + str(Network.match_total_rounds)
	if time_slider:
		time_slider.value = Network.round_time_limit
		time_label.text = "Time: " + str(Network.round_time_limit) + "s"
	if balls_slider:
		balls_slider.value = Network.round_ball_count
		balls_label.text = "Balls: " + str(Network.round_ball_count)

func _on_queue_joined():
	status_label.text = "SEARCHING FOR PLAYERS..."

func _on_lobby_created(code):
	status_label.text = "WAITING FOR FRIEND...\nCODE: " + str(code)
	code_input.text = str(code)
	code_input.editable = false
	host_panel.visible = true
	join_panel.visible = false
	quick_match_btn.visible = false
	copy_btn.visible = true
	cancel_btn.visible = true
	nickname_input.visible = false

func _on_match_found(role):
	status_label.text = "MATCH FOUND!\nYOU WILL BE " + role.to_upper() + "\nACCEPT?"
	copy_btn.visible = false
	cancel_btn.visible = false
	confirmation_container.visible = true
	nickname_input.visible = false
	host_panel.visible = false
	join_panel.visible = false
	
func _on_match_cancelled():
	status_label.text = "Match Cancelled."
	await get_tree().create_timer(1.2).timeout
	_reset_to_start()

func _on_joined_lobby():
	status_label.text = "MATCH ACCEPTED! Connecting WebRTC..."
	confirmation_container.visible = false
	cancel_btn.visible = false
	nickname_input.visible = false
	host_panel.visible = false
	join_panel.visible = false

func _on_game_error(msg):
	_reset_to_start()
	status_label.text = "Error: " + str(msg)

func _on_game_started():
	status_label.text = "STARTING GAME!"
	await get_tree().create_timer(1.0).timeout
	visible = false

func _on_back_pressed():
	visible = false
	var m = get_node_or_null("/root/Master")
	if m:
		var opts = m.get_node_or_null("CanvasLayer/OptionsContainer")
		if opts:
			opts.show()
			
	Network.cancel_matchmaking()
	if Network.multiplayer.has_multiplayer_peer():
		Network.multiplayer.multiplayer_peer.close()

func _on_copy_pressed():
	DisplayServer.clipboard_set(code_input.text)
	if code_input.has_focus():
		code_input.release_focus()
	if nickname_input.has_focus():
		nickname_input.release_focus()
	copy_btn.text = "COPIED!"
	await get_tree().create_timer(1.5).timeout
	if is_instance_valid(copy_btn):
		copy_btn.text = "COPY CODE"

func _on_nickname_changed(new_text: String):
	Network.player_name = new_text.strip_edges()
	if Network.player_name.is_empty():
		Network.player_name = "Player_" + str(randi_range(100, 999))
