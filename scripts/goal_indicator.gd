extends ColorRect
class_name GoalIndicator

var goal_in_progress = false
var tween = null

func goal(bonus = false):
	if bonus:
		modulate = Color.yellow
	else:
		modulate = Color.white
	if not goal_in_progress:
		tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "modulate:a", 1.0, 0.1)
		tween.tween_property(self, "modulate:a", 0.0, 0.1)
		tween.tween_callback(self, "set_goal_in_progress", [false])
		tween.play()
	else:
		tween.stop()
		tween.tween_property(self, "modulate:a", 1.0, 0.1)
		tween.tween_property(self, "modulate:a", 0.0, 0.1)
		tween.tween_callback(self, "set_goal_in_progress", [false])
		tween.play()


func set_goal_in_progress(bo: bool):
	goal_in_progress = bo
