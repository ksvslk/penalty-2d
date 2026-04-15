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

func _ready():
	if OS.get_name() == "iOS":
		bonus.hide()

	if OS.get_name() == "Android" or OS.get_name() == "iOS":
		get_tree().get_root().size_changed.connect(update_margins)
		update_margins()

	# PRECISE MODAL LOGIC: Center the Option lists dynamically
	var menus = [play_games_list, bonus_list, options_list, $SelectCountry/VBoxContainer]
	for m in menus:
		if m != null:
			# Strip strict rigid offsets that caused them to be at the bottom
			m.anchor_top = 0.5
			m.anchor_bottom = 0.5
			m.anchor_left = 0.5
			m.anchor_right = 0.5
			m.offset_left = -300
			m.offset_right = 300
			m.offset_top = -250
			m.offset_bottom = 250
			m.alignment = BoxContainer.ALIGNMENT_CENTER
			m.add_theme_constant_override("separation", 20)
			
			# Add explicit dark backgrounds so the menu isn't transparent
			var background = ColorRect.new()
			background.color = Color(0, 0, 0, 0.95)
			background.set_anchors_preset(Control.PRESET_FULL_RECT)
			background.mouse_filter = Control.MOUSE_FILTER_IGNORE
			m.add_child(background)
			m.move_child(background, 0)
			
	# Convert BackButton from invisible blocker to Translucent Fullscreen Dim
	if back_button != null:
		var dim = ColorRect.new()
		dim.color = Color(0, 0, 0, 0.8)
		dim.set_anchors_preset(Control.PRESET_FULL_RECT)
		dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
		back_button.add_child(dim)
		back_button.move_child(dim, 0)

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
		offset_bottom = -safe_bottom



func _on_Options_pressed():
	options_list.visible = true
	currently_visible_suboption = options_list
	back_button.visible = true
	total_score.text = "Total score: " + str(Data.get_total_score())
	_hide_all_menu_buttons()


func _on_Levels_pressed():
	level_scroller.visible = true
	options_list.hide()
	currently_visible_suboption = level_scroller


func switch_level_now(index):
	_on_BackButton_pressed()
	emit_signal("switch_level", index)


func _on_Bonus_pressed():
	bonus_list.visible = true
	currently_visible_suboption = bonus_list
	back_button.visible = true
	_hide_all_menu_buttons()


func _on_PlayGames_pressed():
	play_games_list.visible = true
	currently_visible_suboption = play_games_list
	back_button.visible = true
	_hide_all_menu_buttons()
	

func _hide_all_menu_buttons():
	play_games.visible = false
	bonus.visible = false
	options.visible = false


func _show_all_menu_buttons():
	play_games.visible = true
	if OS.get_name() != "iOS":
		bonus.visible = true
	options.visible = true


func _on_BackButton_pressed():
	currently_visible_suboption.visible = false
	currently_visible_suboption = null
	back_button.visible = false
	_show_all_menu_buttons()


func _on_ShowLeaderboard_pressed():
	GPack.show_leaderboard(C.leaderboard_goat)
	_on_BackButton_pressed()


func _on_ShowAchievements_pressed():
	GPack.show_achievements()
	_on_BackButton_pressed()


func _on_BackButton_gui_input(event):
	if event is InputEventMouseButton and event.is_pressed():
		_on_BackButton_pressed()
