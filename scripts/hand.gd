extends Sprite2D
var start_position: Vector2
var final_position: Vector2

func _ready():
	z_index = 2
	if start_position:
		global_position = Vector2(get_viewport_rect().size.x / 2, start_position.y)
		start_position = global_position
		final_position = Vector2(global_position.x, final_position.y)
	if final_position:
		var tween := get_tree().create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
		tween.tween_property(self, "modulate:a", 1.0, 0.1)
		tween.tween_property(self, "global_position", final_position, 2.0)
		tween.tween_property(self, "modulate:a", 0.0, 1.0)
		tween.tween_property(self, "global_position", start_position, 0.0)
		tween.set_loops(3)
		tween.play()
