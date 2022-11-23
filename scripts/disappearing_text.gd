extends Label

var tween = null

func fade_out_text(country):
	if tween is SceneTreeTween:
		tween.stop()
	modulate.a = 1.0
	text = country
	visible = true
	tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "modulate:a", 0.0, 4.0)
	tween.tween_callback(self, "set_visible", [false])
	tween.play()
