extends Node2D
class_name Mediator

export var ball_count := 15
export var time_limit := 40


var swish_scene = load("res://scenes/Swish.tscn")
var ball_scene = load("res://scenes/Ball.tscn")
var ball_dict = {}
var round_is_active = true
onready var restart = $Restart
onready var goal_indicator = $GoalIndicator
onready var goal_sound = $GoalSound
onready var bonus_goal_sound = $BonusGoalSound
onready var whistle_sound = $WhistleSound
onready var target_score = $TargetScore

onready var time = $Display/Time
onready var score = $Display/Score
onready var highest = $Display/Highest
var balls = []
onready var goal_keeper = $GoalKeeper

const SCORE_ADDED = 2
const SCORE_ADDED_BONUS = 3
const BONUS_TIME = 15

onready var opponent = $Opponent
var holding_ball := false


func _ready():
	get_tree().paused = true
	Data.connect("best_score_updated", highest, "set_text")
	Data.connect("level_info_updated", self, "_update_level_info")
	Data.set_level_info()
	for i in ball_count:
		var ball = ball_scene.instance() as Ball
		ball.mediator = self
		ball.scale = ball.scale / 2
		add_child_below_node(whistle_sound, ball)
		balls.push_front(ball)
	goal_keeper.balls = balls


func add_ball():
	var ball = ball_scene.instance() as Ball
	ball.mediator = self
	ball.scale = ball.scale / 2
	add_child_below_node(whistle_sound, ball)
	balls.push_front(ball)
	goal_keeper.balls = balls


func remove_ball():
	var ball = balls.pop_front()
	ball.queue_free()
	goal_keeper.balls = balls
	

func _update_level_info(dict: Dictionary):
	highest.text = str(dict[C.BEST_SCORE])
	time_limit = dict[C.TIME_LIMIT]
	goal_keeper.flag.texture = load("res://art/flag/" + dict[C.FLAG] + ".png")
	goal_keeper.speed = dict[C.DIFFICULTY]
	target_score.text = "Target: " + str(dict[C.PASS_SCORE])
	get_tree().paused = false
	start_level()
	opponent.fade_out_text(dict[C.COUNTRY])


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
		var bonus = time.start_time <= BONUS_TIME
		goal_indicator.goal(bonus)
		if bonus:
			bonus_goal_sound.play()
			score.text = str(int(score.text) + SCORE_ADDED_BONUS)
		else:
			goal_sound.play()
			score.text = str(int(score.text) + SCORE_ADDED)


func _on_Time_round_done():
	Data.update_score(int(score.text))
	whistle_sound.play()
	round_is_active = false
	restart.visible = true
	restart.text = "SCORE: " + score.text + "\n RESTART?"


func _on_Restart_gui_input(event):
	if event.is_pressed():
		start_level()


func start_level():
	(time.timer as Timer).stop()
	whistle_sound.play()
	round_is_active = true
	time.original_start_time = time_limit
	time.start_time = time_limit
	restart.visible = false
	score.text = str(0)
	time.restart_timer_for_next_round()
