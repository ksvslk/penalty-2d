extends Label

var tween: Tween

func fade_out_text(new_text: String) -> void:
	# If a previous tween animation is running, kill it to start a new one.
	if tween:
		tween.kill()
	
	# Reset the label to a fully visible state with the new text.
	modulate.a = 1.0
	text = new_text
	visible = true
	
	# Create a new tween. In Godot 4, tweens start automatically.
	tween = create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN)
	
	# Animate the alpha property of the modulate color from 1.0 to 0.0 over 4 seconds.
	tween.tween_property(self, "modulate:a", 0.0, 4.0)
	
	# When the animation is finished, call the built-in set_visible() method with 'false' as an argument.
	tween.tween_callback(set_visible.bind(false))
