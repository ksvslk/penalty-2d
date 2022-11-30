extends CPUParticles2D


func _on_Timer_timeout():
	var tween := get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 2.0)
	tween.tween_callback(self, "queue_free")
	tween.play()
