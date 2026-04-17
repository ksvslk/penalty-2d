extends Control

var host_btn: Button
var join_btn: Button
var code_input: LineEdit
var status_label: Label
var back_btn: Button
var copy_btn: Button
var main_container: VBoxContainer

func _ready():
	# Setup UI
	anchors_preset = Control.PRESET_FULL_RECT
	
	var bg = ColorRect.new()
	bg.color = Color(0.05, 0.05, 0.05, 0.96)
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
	
	host_btn = _create_button("CREATE GAME")
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
	join_container.add_child(code_input)
	
	join_btn = _create_button("JOIN")
	join_btn.custom_minimum_size = Vector2(550, 140)
	join_btn.pressed.connect(_on_join_pressed)
	join_container.add_child(join_btn)
	
	copy_btn = _create_button("COPY CODE")
	copy_btn.visible = false
	copy_btn.pressed.connect(_on_copy_pressed)
	main_container.add_child(copy_btn)

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

func _on_host_pressed():
	status_label.text = "Connecting to signaling..."
	Network.connect_to_signaling_server()
	# Wait for connection? Network.gd connects then we can create
	# For simplicity, Network.create_game calls connect internally or we wait
	# Let's assume connect is async.
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

func _on_lobby_created(code):
	status_label.text = "WAITING FOR PLAYER...\nCODE: " + str(code)
	code_input.text = str(code)
	code_input.editable = false
	host_btn.visible = false
	join_btn.visible = false
	copy_btn.visible = true

func _on_joined_lobby():
	status_label.text = "Joined! Waiting for host..."
	host_btn.visible = false
	join_btn.visible = false

func _on_game_error(msg):
	status_label.text = "Error: " + str(msg)
	host_btn.visible = true
	join_btn.visible = true
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
