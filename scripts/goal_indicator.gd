extends ColorRect
class_name GoalIndicator

var tween: Tween

func goal(bonus := false) -> void:
	# If a previous tween animation is still running, kill it.
	# This ensures the flash effect restarts correctly if triggered rapidly.
	if tween:
		tween.kill()

	# Set the base color for the flash. The alpha will be handled by the tween.
	if bonus:
		modulate = Color.YELLOW
	else:
		modulate = Color.WHITE

	# Create a new tween for the animation. In Godot 4, tweens start automatically.
	tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)

	# Create the animation sequence:
	# 1. Flash to full opacity over 0.1 seconds.
	tween.tween_property(self, "modulate:a", 1.0, 0.1)
	# 2. Fade back to fully transparent over 0.1 seconds.
	tween.tween_property(self, "modulate:a", 0.0, 0.1)
