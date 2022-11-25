extends Light2D

var random_position = Vector2.ZERO
var current_target_destination = Vector2.ZERO
export var speed := 2


func _process(delta):
	var x = move_toward(global_position.x, current_target_destination.x, delta)
	var y = move_toward(global_position.y, current_target_destination.y, delta)
	global_position= lerp(global_position, Vector2(current_target_destination.x, current_target_destination.y), delta * speed)


func appear():
	print("appear")
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "color:a", 1.0, 2)
	tween.tween_callback(get_parent(), "light_on")
	tween.play()


func disappear():
	print("DISAPPEAR")
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "color:a", 0.0, 1.5)
	tween.tween_callback(get_parent(), "light_off")
	tween.play()
