extends Sprite

func _ready():
	var tween := create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0.0, 1)
	tween.tween_callback(self, "queue_free")
	tween.play()
