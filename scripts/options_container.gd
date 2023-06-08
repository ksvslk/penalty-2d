extends Control

onready var play_games = $HBoxContainer/PlayGames
onready var play_games_list = $PlayGamesList
onready var back_button = $BackButton

onready var bonus = $HBoxContainer/Bonus
onready var bonus_list = $BonusList
onready var options_list = $OptionsList
onready var options = $HBoxContainer/Options
onready var total_score = $OptionsList/TotalScore

onready var level_scroller = $LevelScroller
var currently_visible_suboption = null

signal switch_level

func _ready():
	if OS.get_name() == "iOS":
		bonus.hide()


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


func switch_level(index):
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
