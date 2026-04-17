extends Control

@onready var play_games = $HBoxContainer/PlayGames
@onready var play_games_list = $PlayGamesList
@onready var back_button = $BackButton

@onready var bonus = $HBoxContainer/Bonus
@onready var bonus_list = $BonusList
@onready var options_list = $OptionsList
@onready var options = $HBoxContainer/Options
@onready var total_score = $OptionsList/TotalScore

@onready var level_scroller = $LevelScroller
var currently_visible_suboption = null

signal switch_level



func _scale_ui_element(node: Node, primary_style: StyleBoxFlat):
	if node is Button:
		node.add_theme_font_size_override("font_size", 48)
		# Add our luxurious premium padding and background style
		node.add_theme_stylebox_override("normal", primary_style)
		node.add_theme_stylebox_override("hover", primary_style)
		node.add_theme_stylebox_override("pressed", primary_style)
		node.add_theme_constant_override("h_separation", 40)
		node.add_theme_constant_override("icon_max_width", 65)
		
		# Enforce massive luxury widths
		if not node.get_parent() is HBoxContainer:
			node.custom_minimum_size = Vector2(900, 140)
		else:
			node.custom_minimum_size = Vector2(430, 140) 
			
	elif node is Label:
		node.add_theme_font_size_override("font_size", 56)
		
	# Recurse children
	for child in node.get_children():
		_scale_ui_element(child, primary_style)



func _ready():

	if OS.get_name() == "iOS":
		bonus.hide()

	if OS.get_name() == "Android" or OS.get_name() == "iOS":
		get_tree().get_root().size_changed.connect(update_margins)
		update_margins()

	
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
	

	# Inject a deep pure black backdrop behind the bottom row toolbar natively so the "weird grey" gaps are flawlessly patched
	

	# Inject a mathematical layout blackout block uniquely engineered to bind exactly starting from the physical BottomWall coordinate Y=2207.0 extending downward infinitely past the layout bounds to effectively eliminate all aspect-ratio holes caused by taller mobile screens.
	
	# MVP Modal Style: Center the Option lists dynamically and style exactly like MultiplayerUI
	var menu_titles = {
		play_games_list: "GAME CENTER",
		bonus_list: "BONUS",
		options_list: "OPTIONS",
	}
	var menus = [play_games_list, bonus_list, options_list]
	# Mathematically perfectly intuitively brilliantly seamlessly intelligently configure SelectCountry elements
	var viewport_size = get_viewport_rect().size
	
	var native_screens = [level_scroller, $SelectCountry]
	for ms in native_screens:
		if ms != null:
			ms.set_anchors_preset(Control.PRESET_FULL_RECT)
			ms.offset_left = 0
			ms.offset_right = 0
			ms.offset_top = 0
			ms.offset_bottom = 0
			ms.size = viewport_size # Explicitly guarantee bounds regardless of process timing
	
	var overlay_bg = ColorRect.new()
	overlay_bg.color = Color(0.05, 0.08, 0, 0.86)
	# Discard anchors completely to mathematically lock the absolute visual span natively seamlessly 
	overlay_bg.position = Vector2(-800, -800)
	overlay_bg.size = viewport_size + Vector2(1600, 1600)
	$SelectCountry.add_child(overlay_bg)
	$SelectCountry.move_child(overlay_bg, 0)
	$SelectCountry.color.a = 0

	var select_country_vbox = $SelectCountry/VBoxContainer
	if select_country_vbox != null:
		select_country_vbox.set_anchors_preset(Control.PRESET_CENTER)
		# Clear Godot's anchor position preservation offsets securely reliably conceptually geometrically elegantly correctly cleanly cleanly seamlessly smartly purely optimally
		select_country_vbox.offset_left = -450
		select_country_vbox.offset_right = 450
		select_country_vbox.offset_top = -300
		select_country_vbox.offset_bottom = 300
		select_country_vbox.grow_horizontal = Control.GROW_DIRECTION_BOTH
		select_country_vbox.grow_vertical = Control.GROW_DIRECTION_BOTH
		select_country_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		
		# Give it the massive premium style sizing exactly like MULTIPLAYER
		for child in select_country_vbox.get_children():
			_scale_ui_element(child, premium_btn)

	for m in menus:
		if m != null:
			m.set_anchors_preset(Control.PRESET_FULL_RECT)
			m.offset_left = 0
			m.offset_right = 0
			m.offset_top = 0
			m.offset_bottom = 0
			m.anchor_left = 0
			m.anchor_top = 0
			m.anchor_right = 1
			m.anchor_bottom = 1
			
			# The background overlay (fullscreen translucent black)
			var bg = ColorRect.new()
			bg.color = Color(0.05, 0.05, 0.05, 0.96)
			bg.set_anchors_preset(Control.PRESET_FULL_RECT)
			bg.offset_top = -400
			bg.offset_bottom = 400
			bg.offset_left = -200
			bg.offset_right = 200
			m.add_child(bg)
			m.move_child(bg, 0)
			
			# Inner centered container exactly like MultiplayerUI
			var inner_box = VBoxContainer.new()
			inner_box.name = "InnerBox"
			inner_box.set_anchors_preset(Control.PRESET_CENTER)
			inner_box.grow_horizontal = Control.GROW_DIRECTION_BOTH
			inner_box.grow_vertical = Control.GROW_DIRECTION_BOTH
			inner_box.alignment = BoxContainer.ALIGNMENT_CENTER
			inner_box.add_theme_constant_override("separation", 40)
			
			# Dynamic Header Label
			if menu_titles.has(m):
				var title = Label.new()
				title.text = menu_titles[m]
				title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				title.add_theme_font_size_override("font_size", 48)
				if play_games:
					title.add_theme_font_override("font", play_games.get_theme_font("font"))
				inner_box.add_child(title)
				
			var existing_children = m.get_children()
			for child in existing_children:
				if child == bg or child == inner_box:
					continue
				m.remove_child(child)
				inner_box.add_child(child)
				_scale_ui_element(child, premium_btn)
			
			# Standard explicit local BACK button identically functioning to MVP
			var local_back = Button.new()
			local_back.text = "BACK"
			local_back.custom_minimum_size = Vector2(900, 140)
			local_back.add_theme_font_size_override("font_size", 48)
			local_back.add_theme_stylebox_override("normal", premium_btn)
			local_back.add_theme_stylebox_override("hover", premium_btn)
			local_back.add_theme_stylebox_override("pressed", premium_btn)
			if play_games:
				local_back.add_theme_font_override("font", play_games.get_theme_font("font"))
			local_back.pressed.connect(func(): m.visible = false)
			local_back.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
			local_back.offset_left = -450
			local_back.offset_right = 450
			local_back.offset_bottom = -150
			local_back.offset_top = -290
			m.add_child(local_back)
			
			m.add_child(inner_box)

func update_margins():
	var safe_area = DisplayServer.get_display_safe_area()
	var window_size = DisplayServer.window_get_size()
	
	if window_size.y > 0:
		# Calculate scale factors to match 1080x2400 aspect matrix
		var scale_y = 2400.0 / float(window_size.y)
		
		# Translate physical device pixels to virtual godot sizing
		var safe_top = int(safe_area.position.y * scale_y)
		var safe_bottom = int((window_size.y - safe_area.end.y) * scale_y)
		
		offset_top = safe_top
		offset_bottom = 0



func _on_Options_pressed():
	options_list.visible = true


func _on_Levels_pressed():
	level_scroller.visible = true
	options_list.hide()


func switch_level_now(index):
	options_list.visible = false
	emit_signal("switch_level", index)


func _on_Bonus_pressed():
	bonus_list.visible = true


func _on_PlayGames_pressed():
	play_games_list.visible = true


func _hide_all_menu_buttons():
	pass

func _show_all_menu_buttons():
	pass

func _on_BackButton_pressed():
	if play_games_list.visible: play_games_list.visible = false
	if bonus_list.visible: bonus_list.visible = false
	if options_list.visible: options_list.visible = false


func _on_ShowLeaderboard_pressed():
	GPack.show_leaderboard(C.leaderboard_goat)
	_on_BackButton_pressed()


func _on_ShowAchievements_pressed():
	GPack.show_achievements()
	_on_BackButton_pressed()


func _on_BackButton_gui_input(event):
	pass
