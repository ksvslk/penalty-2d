extends Node2D
class_name Mediator

export var ball_count := 15
export var bonus_balls := 0
export var time_limit := 40


var swish_scene = load("res://scenes/Swish.tscn")
var ball_scene = load("res://scenes/Ball.tscn")
var add_ball_effect = load("res://scenes/SpeedlinesShineEffect.tscn")
var ball_dict = {}
var round_is_active = true
var new_high_score_announced = false
var goal_counter := 0
var swipe_counter := 0
var ad_shown_counter := 0


onready var continue_button = $Continue
onready var restart = $Restart
onready var goal_indicator = $GoalIndicator
onready var goal_sound = $GoalSound
onready var bonus_goal_sound = $BonusGoalSound
onready var whistle_sound = $WhistleSound
onready var target_score = $TargetScore
onready var level_passed = $LevelPassed
onready var start_timer = $StartTimer
onready var start_countdown = $StartCountdown
onready var tick_sound = $TickSound
onready var celebrate = $Celebrate

onready var time = $Display/Time
onready var score = $Display/Score
onready var highest = $Display/Highest
var balls = []
onready var goal_keeper = $GoalKeeper
onready var watch_ad = $WatchAd

const SCORE_ADDED = 2
const SCORE_ADDED_BONUS = 3
const BONUS_TIME = 15
var countdown = 3

onready var message = $Message
var holding_ball := false
signal level_passed
signal start_level

func _try_to_show_ad():
	if Data.is_intermediate_ads_enabled() and not Data.is_two_balls_purchased():
		print("_try_to_show_ad")
		ad_shown_counter += 1
		if ad_shown_counter == 1:
			print("5")
			if int(Data.current_level) >= 10:
				print("over level 10")
				GPack.show_interstitial_ad()
			ad_shown_counter = 0


func start_game():
	if Data.is_intermediate_ads_enabled() and not Data.is_two_balls_purchased() and int(Data.current_level) >= 10:
		GPack.load_interstitial_ad()
	round_is_active = false
	Data.connect("best_score_updated", highest, "set_text")
	Data.connect("level_info_updated", self, "_update_level_info")
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
	var ball = ball_scene.instance() as Ball
	ball.mediator = self
	ball.scale = ball.scale / 2
	ball.set_flag(Data.get_player_team())
	ball.global_position = pos.position
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
	ball_count = min(C.default_balls_count + dict[C.REWARDED_BALLS] + dict[C.ETERNAL_BALLS], 10)
	bonus_balls = dict[C.ETERNAL_BALLS] + dict[C.REWARDED_BALLS]
	_add_all_balls()
	round_is_active = false
	time.timer.stop()
	restart.visible = false
	continue_button.visible = false
	highest.text = str(dict[C.BEST_SCORE])
	time_limit = dict[C.TIME_LIMIT]
	goal_keeper.set_flag(load("res://art/flag/" + dict[C.FLAG] + ".png"))
	goal_keeper.speed = dict[C.DIFFICULTY]
	target_score.text = "Target: " + str(dict[C.PASS_SCORE])
	level_start_countdown()
	message.fade_out_text(dict[C.COUNTRY])
	_check_for_country_achievements(dict[C.COUNTRY], dict[C.FLAG])
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
		60:
			GPack.unlock_achievement(C.achievement_60_second_rounds)
		70:
			GPack.unlock_achievement(C.achievement_70_second_rounds)


func add_swish(name: String, points: Array):
	if ball_dict.has(name):
		ball_dict[name].add_point(points[1])
		ball_dict[name].update()
	else:
		var swish = swish_scene.instance() as Line2D
		swish.set_as_toplevel(true)
		for p in points:
			swish.add_point(p)
		add_child(swish)
		swish.update()
		ball_dict[name] = swish


func remove_swish(name: String):
	if ball_dict.has(name):
		var line = ball_dict[name] as Line2D
		ball_dict.erase(name)
		var tween := create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
		tween.tween_property(line, "modulate:a", 0.0, 2.0)
		tween.tween_callback(line, "queue_free")
		tween.play()


func _on_Goal_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if round_is_active:
		goal_counter += 1
		var time_left = time.start_time
		var bonus = time.start_time <= BONUS_TIME
		goal_indicator.goal(bonus)
		if bonus:
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
	if eligible and body.global_position.x <= 105 or body.global_position.x >= 975:
		GPack.unlock_achievement(C.achievement_shot_to_corner)
	
	
func _check_center_shot(body):
	var eligible = int(Data.current_level) > 49
	if eligible and body.global_position.x >= 530 and body.global_position.x <= 550:
		GPack.unlock_achievement(C.achievement_shot_to_center)


func _check_first_second_goal_achievement():
	if time.get_seconds_passed() <= 1:
		GPack.unlock_achievement(C.achievement_goal_on_first_second)


func _play_fanfares_when_level_passed(time_left = 1337) -> void:
	if int(score.text) >= int(target_score.text):
		target_score.modulate = Color.greenyellow
		var next_country = Data.unlock_next_level()
		if not next_country.empty():
			if time_left <= 1:
				GPack.unlock_achievement(C.achievement_last_second_pass)
			message.fade_out_text("Unlocked " + next_country + "!")
			level_passed.play()


func _check_high_score() -> void:
	if int(score.text) > int(highest.text) and int(highest.text) != 0 and not new_high_score_announced:
		new_high_score_announced = true
		level_passed.play()
		message.fade_out_text("New high score!")
			

func _on_Time_round_done():
	_try_to_show_ad()
	Data.update_score(int(score.text))
	whistle_sound.play()
	round_is_active = false
	var passed = int(score.text) >= int(target_score.text)
	if passed:
		_check_champion_achievement()
		_check_all_goals_achievement()
		celebrate.play()
		emit_signal("level_passed")
		if int(Data.current_level) != 211:
			continue_button.visible = true
	else:
		if Data.get_max_balls_to_add_count() > 0 and GPack.is_rewarded_ad_loaded():
			watch_ad.visible = true
		GPack.log_event(C.event_fail_level, {
			"level":int(Data.current_level),
			"score":int(score.text)
		}) 
	restart.visible = true
	if not GPack.is_rewarded_ad_loaded():
		GPack.load_rewarded_ad()


func _check_all_goals_achievement():
	if goal_counter >= swipe_counter:
		GPack.unlock_achievement(C.achievement_only_goals)


func _check_champion_achievement():
	if int(Data.current_level) == 211:
		GPack.unlock_achievement(C.achievement_world_champion)


func _on_Restart_gui_input(event):
	if event.is_pressed():
		level_start_countdown()


func level_start_countdown():
	emit_signal("start_level")
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
	target_score.modulate = Color.yellow
	time.restart_timer_for_next_round()


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
