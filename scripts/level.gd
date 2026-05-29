extends Node2D
class_name Mediator

@export var ball_count := 15
@export var bonus_balls := 0
@export var time_limit := 40


var swish_scene = load("res://scenes/Swish.tscn")
var ball_scene = load("res://scenes/Ball.tscn")


var ball_dict = {}
var round_is_active = true
var new_high_score_announced = false
var goal_counter := 0
var swipe_counter := 0

@onready var fast_forward_button = $FastForwardButton

@onready var continue_button = $Continue
@onready var restart = $Restart
@onready var goal_indicator = $GoalIndicator
@onready var goal_sound = $GoalSound
@onready var bonus_goal_sound = $BonusGoalSound
@onready var whistle_sound = $WhistleSound
@onready var target_score = $TargetScore
@onready var level_passed_sound = $LevelPassed
@onready var start_timer = $StartTimer
@onready var start_countdown = $StartCountdown
@onready var tick_sound = $TickSound
@onready var celebrate = $Celebrate


@onready var time = $Display/Time
@onready var score = $Display/Score
@onready var highest = $Display/Highest
var balls = []
@onready var goal_keeper = $GoalKeeper
@onready var watch_ad = $WatchAd

const SHOW_REVIEW_LEVEL = 7
const LAST_LEVEL = 211
const SCORE_ADDED = 2
const SCORE_ADDED_BONUS = 3
const BONUS_TIME = 15
const SHOW_ADS_INTERVAL = 5
const SHOW_ADS_LEVEL_AND_UP = 10
var ad_shown_counter := 0

var countdown = 3

@onready var message = $Message
var holding_ball := false
signal level_passed
signal start_level
signal commercial_break
func _ready():
	if has_meta("shifted"):
		return
	if OS.get_name() != "macOS":
		await get_tree().process_frame
		var viewport_height = get_viewport_rect().size.y
		var shift = viewport_height - 2400 - C.get_bottom_safe_margin()
		$FloorBlackout.position.y = shift
		set_meta("shifted", true)

func _try_to_show_ad():
	if Data.is_intermediate_ads_enabled() and not Data.is_two_balls_purchased():
		ad_shown_counter += 1
		if ad_shown_counter == SHOW_ADS_INTERVAL:
			if int(Data.current_level) >= SHOW_ADS_LEVEL_AND_UP and GPack.is_interstitial_ad_loaded():
				emit_signal("commercial_break")
			ad_shown_counter = 0


func start_game():
	_add_tutorial()
	if Data.is_intermediate_ads_enabled() and not Data.is_two_balls_purchased() and int(Data.current_level) >= SHOW_ADS_LEVEL_AND_UP:
		GPack.load_interstitial_ad()
	round_is_active = false
	if not Data.best_score_updated.is_connected(highest.set_text):
		Data.best_score_updated.connect(highest.set_text)
	if not Data.level_info_updated.is_connected(self._update_level_info):
		Data.level_info_updated.connect(self._update_level_info)
	Data.set_level_info()


func _remove_all_balls():
	var balls_container = $BallsContainer
	balls.clear()
	for b in balls_container.get_children():
		balls_container.remove_child(b)

	
func _add_all_balls():
	_remove_all_balls()
	var ball_positions = $BallPositions.get_children()
	for i in range(0, ball_count):
		if bonus_balls > 0 and i > 2:
			add_ball(true, true, ball_positions[i])
			bonus_balls -= 1
		else:
			add_ball(false, true, ball_positions[i])


func add_ball(eternal_ball = false, adding_all_balls = false, pos = $BallPositions.get_children()[0]):
	var ball = ball_scene.instantiate() as Ball
	ball.mediator = self
	ball.scale = ball.scale / 2
	ball.set_flag(Data.get_player_team())
	ball.global_position = pos.global_position
	if eternal_ball:
		ball.activate_bonus_patch()
		if not adding_all_balls:
			ball.global_position = $BallPositions/SpecialPosition.global_position - Vector2(0, 400)
	$BallsContainer.add_child(ball)
	balls.push_front(ball)
	goal_keeper.balls = balls


func remove_ball():
	var ball = balls.pop_front()
	ball.queue_free()
	goal_keeper.balls = balls
	
	

func _update_level_info(dict: Dictionary):
	if get_node_or_null("Trophy"):
		remove_child(get_node_or_null("Trophy"))
	ball_count = min(C.default_balls_count + int(dict.get(C.REWARDED_BALLS, 0)) + int(dict.get(C.ETERNAL_BALLS, 0)), 10)
	bonus_balls = int(dict.get(C.ETERNAL_BALLS, 0)) + int(dict.get(C.REWARDED_BALLS, 0))
	_add_all_balls()
	round_is_active = false
	time.timer.stop()
	restart.visible = false
	continue_button.visible = false
	highest.text = str(int(dict.get(C.BEST_SCORE, 0)))
	time_limit = int(dict.get(C.TIME_LIMIT, 0))
	goal_keeper.set_flag(load(C.get_flag_path() + str(dict[C.FLAG]).replace("\"", "") + C.get_extension()))
	goal_keeper.speed = dict[C.DIFFICULTY]
	target_score.text = "Target: " + str(int(dict.get(C.PASS_SCORE, 0)))
	level_start_countdown()
	message.fade_out_text(dict[C.COUNTRY])
	_check_for_country_achievements(str(dict[C.COUNTRY]).replace("\"", ""), str(dict[C.FLAG]).replace("\"", ""))
	_check_for_time_limit_achievements()
	

func _check_for_country_achievements(country: String, flag: String):
	if country == "Australia":
		GPack.unlock_achievement(C.achievement_all_6_continents)
	if flag == Data.get_player_team():
		GPack.unlock_achievement(C.achievement_same_country)


func _check_for_time_limit_achievements():
	match int(Data.current_level):
		50:
			GPack.unlock_achievement(C.achievement_50_second_rounds)
		100:
			GPack.unlock_achievement(C.achievement_60_second_rounds)
		150:
			GPack.unlock_achievement(C.achievement_70_second_rounds)


func add_swish(swish_name: String, points: Array):
	if ball_dict.has(swish_name):
		ball_dict[swish_name].add_point(points[1])
		ball_dict[swish_name].queue_redraw()
	else:
		var swish = swish_scene.instantiate() as Line2D
		swish.top_level = true
		for p in points:
			swish.add_point(p)
		add_child(swish)
		swish.queue_redraw()
		ball_dict[swish_name] = swish


func remove_swish(swish_name: String):
	if ball_dict.has(swish_name):
		var line = ball_dict[swish_name] as Line2D
		ball_dict.erase(swish_name)
		var tween := create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
		tween.tween_property(line, "modulate:a", 0.0, 2.0)
		tween.tween_callback(line.queue_free)
		tween.play()


func vibrate(duration: int = 50):
	Input.vibrate_handheld(duration)


func _on_Goal_body_shape_entered(_body_rid, body, _body_shape_index, _local_shape_index):
	if round_is_active:
		goal_counter += 1
		var time_left = time.start_time
		var bonus = time.start_time <= BONUS_TIME
		goal_indicator.goal(bonus)
		if bonus:
			vibrate()
			bonus_goal_sound.play()
			score.text = str(int(score.text) + SCORE_ADDED_BONUS)
		else:
			goal_sound.play()
			score.text = str(int(score.text) + SCORE_ADDED)
		_check_corner_shot(body)
		_check_center_shot(body)
		_play_fanfares_when_level_passed(time_left)
		_check_high_score()
		_check_first_second_goal_achievement()


func _check_corner_shot(body):
	var eligible = int(Data.current_level) > 99
	if eligible and (body.global_position.x <= 100 or body.global_position.x >= 980):
		GPack.unlock_achievement(C.achievement_shot_to_corner_100_plus)
	
	
func _check_center_shot(body):
	var eligible = int(Data.current_level) > 49
	if eligible and (body.global_position.x >= 530 and body.global_position.x <= 550):
		GPack.unlock_achievement(C.achievement_shot_to_center_50_plus)


func _check_first_second_goal_achievement():
	if time.get_seconds_passed() <= 1:
		GPack.unlock_achievement(C.achievement_goal_on_first_second)


func _play_fanfares_when_level_passed(time_left = 1337) -> void:
	if int(score.text) >= int(target_score.text):
		target_score.modulate = Color.GREEN_YELLOW
		var next_country = Data.unlock_next_level()
		if not next_country.is_empty():
			if time_left <= 1:
				GPack.unlock_achievement(C.achievement_last_second_pass)
			message.fade_out_text("Unlocked " + next_country + "!")
			fast_forward_button.visible = true
			level_passed_sound.play()


func _check_high_score() -> void:
	if int(score.text) > int(highest.text) and int(highest.text) != 0 and not new_high_score_announced:
		new_high_score_announced = true
		level_passed_sound.play()
		message.fade_out_text("New high score!")
			

func _on_Time_round_done():
	Data.update_score(int(score.text))
	whistle_sound.play()
	round_is_active = false
	var passed = int(score.text) >= int(target_score.text)
	if passed:
		var clevel = int(Data.current_level)
		if clevel == SHOW_REVIEW_LEVEL:
			get_parent().show_review()
		_check_champion_achievement()
		_check_all_goals_achievement()
		celebrate.play()
		emit_signal("level_passed")
		if clevel != LAST_LEVEL:
			continue_button.visible = true
	else:
		if Data.get_max_balls_to_add_count() > 0 and GPack.is_rewarded_ad_loaded() and OS.get_name() != "iOS":
			watch_ad.visible = true
		GPack.log_event(C.event_fail_level, {
			"level":int(Data.current_level),
			"score":int(score.text)
		}) 
	restart.visible = true
	if not GPack.is_rewarded_ad_loaded():
		GPack.load_rewarded_ad()
	_try_to_show_ad()


func _check_all_goals_achievement():
	if goal_counter >= swipe_counter:
		GPack.unlock_achievement(C.achievement_only_goals)


func _check_champion_achievement():
	if int(Data.current_level) == LAST_LEVEL:
		var trophy = load("res://scenes/Trophy.tscn").instantiate()
		$TargetScore.add_sibling(trophy)
		GPack.unlock_achievement(C.achievement_world_champion)


func _on_Restart_gui_input(event):
	if event.is_pressed():
		level_start_countdown()


func level_start_countdown():
	emit_signal("start_level")
	fast_forward_button.visible = false
	celebrate.stop()
	restart.visible = false
	watch_ad.visible = false
	continue_button.visible = false
	start_countdown.visible = true
	swipe_counter = 0
	goal_counter = 0
	countdown = 3
	start_countdown.text = str(countdown)
	start_timer.start()
	tick_sound.play()
	

func round_start_actions():
	emit_signal("start_level")
	(time.timer as Timer).stop()
	whistle_sound.play()
	round_is_active = true
	new_high_score_announced = false
	time.original_start_time = time_limit
	time.start_time = time_limit
	score.text = str(0)
	target_score.modulate = Color.YELLOW
	time.restart_timer_for_next_round()
	
	if Network.connected_peer_id != 0:
		_setup_pvp_round()

func _setup_pvp_round():
	if Network.my_role_this_round == Network.PlayerRole.STRIKER:
		for b in balls:
			b.set_multiplayer_authority(multiplayer.get_unique_id())
		goal_keeper.set_multiplayer_authority(Network.connected_peer_id)
		message.fade_out_text("YOU ARE STRIKER!")
	elif Network.my_role_this_round == Network.PlayerRole.GOALKEEPER:
		for b in balls:
			b.set_multiplayer_authority(Network.connected_peer_id)
		goal_keeper.set_multiplayer_authority(multiplayer.get_unique_id())
		message.fade_out_text("YOU ARE GOALKEEPER!")
		
	# Update UI header for PvP
	if highest.get_parent().has_node("HighestLabel"):
		highest.get_parent().get_node("HighestLabel").text = "OPPONENT:"
	if score.get_parent().has_node("ScoreLabel"):
		score.get_parent().get_node("ScoreLabel").text = "YOU:"
	highest.text = "0"
	target_score.text = "PvP Match"


func _on_StartTimer_timeout():
	if countdown > 1:
		countdown -= 1
		tick_sound.play()
		start_countdown.text = str(countdown)
		start_timer.start()
	else:
		start_countdown.visible = false
		start_timer.stop()
		round_start_actions()


func _add_tutorial():
	if int(Data.current_level) == 1:
		get_tree().paused = true
		var tutorial_scene = load("res://scenes/Tut.tscn").instantiate()
		tutorial_scene.z_index = 3
		$BallPositions.add_sibling(tutorial_scene)


func _on_FastForwardButton_pressed():
	start_timer.stop()
	time.timer.stop()
	fast_forward_button.visible = false
	_on_Time_round_done()
