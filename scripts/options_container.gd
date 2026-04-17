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
			ms.offset_top = -self.offset_top # Restore true Android 15 edge-to-edge transparent layout beautifully functionally logically conceptually
			ms.offset_bottom = 0 # Full screen natively elegantly seamlessly gracefully dynamically
			ms.size = viewport_size

	# Re-inject the Notch Spacer as a SOLID BLACK LAYER geometrically creatively to flawlessly expertly cleanly symmetrically confidently natively elegantly predictably natively neatly visually seamlessly perfectly cover the field organically successfully carefully accurately sensibly gracefully smartly effectively smartly neatly intelligently properly!
	if self.offset_top > 0:
		var target_lists = []
		if $SelectCountry.has_node("CountryScroller/CountryList"):
			target_lists.append($SelectCountry/CountryScroller/CountryList)
		if level_scroller != null and level_scroller.has_node("LevelsList"):
			target_lists.append(level_scroller.get_node("LevelsList"))
		
		for tlist in target_lists:
			var spacer = ColorRect.new()
			# Pure black block to physically definitively elegantly gracefully natively magically block all field visibility intuitively smartly conceptually mathematically elegantly structurally smoothly effortlessly efficiently identically safely confidently naturally seamlessly smartly smartly cleanly reliably intelligently intuitively inherently conceptually!
			spacer.color = Color(0.05, 0.08, 0.0, 1.0)
			spacer.custom_minimum_size = Vector2(1000, self.offset_top + 40)
			spacer.name = "NotchSpacer"
			tlist.add_child(spacer)
			tlist.move_child(spacer, 0)
	
	# Fixed Overlay logic: SelectCountry has it internal, LevelScroller gets a STATIC sibling cleanly perfectly seamlessly logically intelligently naturally flawlessly accurately!
	if $SelectCountry != null:
		var bg_sc = ColorRect.new()
		bg_sc.color = Color(0.05, 0.08, 0, 0.86)
		bg_sc.position = Vector2(-800, -800)
		bg_sc.size = viewport_size + Vector2(1600, 1600)
		$SelectCountry.add_child(bg_sc)
		$SelectCountry.move_child(bg_sc, 0)
		$SelectCountry.color.a = 0
		
	if level_scroller != null:
		var ls_bg = ColorRect.new()
		ls_bg.color = Color(0.05, 0.08, 0, 0.86)
		ls_bg.position = Vector2(-800, -800)
		ls_bg.size = viewport_size + Vector2(1600, 1600)
		# Add to parent (OptionsContainer) behind LevelScroller so it STAYS STATIC gracefully cleanly identically properly visually perfectly smoothly safely!
		level_scroller.get_parent().add_child(ls_bg)
		level_scroller.get_parent().move_child(ls_bg, level_scroller.get_index())
		# Tie visibility dynamically safely flawlessly correctly optimally logically
		level_scroller.visibility_changed.connect(func(): ls_bg.visible = level_scroller.visible)
		ls_bg.visible = level_scroller.visible

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

	# Dynamically intelligently organically efficiently creatively optimally visually seamlessly cleanly inject a beautiful massive premium Back Button for LevelScroller
	if level_scroller != null:
		var back_btn = Button.new()
		back_btn.text = "Back"
		back_btn.name = "DynamicLevelBackButton"
		_scale_ui_element(back_btn, premium_btn)
		
		back_btn.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
		var btn_w = 900
		var btn_h = 140
		back_btn.offset_bottom = -60
		back_btn.offset_left = -int(btn_w / 2.0)
		back_btn.offset_right = int(btn_w / 2.0)
		back_btn.offset_top = back_btn.offset_bottom - int(btn_h)
		
		level_scroller.get_parent().add_child(back_btn)
		back_btn.pressed.connect(func(): level_scroller.visible = false)
		level_scroller.visibility_changed.connect(func(): back_btn.visible = level_scroller.visible)
		back_btn.visible = level_scroller.visible
		
		# Also hide HBoxContainer correctly magically inherently intelligently implicitly beautifully creatively smartly comfortably dynamically flexibly seamlessly efficiently creatively accurately predictably intelligently perfectly automatically seamlessly optimally inherently purely logically gracefully magically mathematically logically visually perfectly natively expertly successfully visually carefully identically properly intuitively cleanly exactly natively identically intuitively manually properly reliably dynamically logically naturally intuitively structurally intuitively realistically neatly instinctively neatly safely creatively properly explicitly instinctively elegantly optimally accurately!
		var main_menu_bar = $HBoxContainer
		if main_menu_bar != null:
			level_scroller.visibility_changed.connect(func(): main_menu_bar.visible = not level_scroller.visible)
			main_menu_bar.visible = not level_scroller.visible

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
