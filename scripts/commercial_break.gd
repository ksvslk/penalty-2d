extends ColorRect

@onready var label: Label = $Label
@onready var timer: Timer = $Timer
var count = 3

# In Godot 4, we use _notification to react to built-in property changes.
# This replaces the old _set(property, value) logic for this use case.
func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		# We only want to start the timer when the node becomes visible,
		# matching the original script's "if value:" check.
		if visible:
			count = 3
			label.text = "Commercial break."
			timer.start()


func _on_Timer_timeout() -> void:
	count -= 1
	if count == 0:
		count = 3
		timer.stop()
		GPack.show_interstitial_ad()
		visible = false
	else:
		label.text += "."
		timer.start()
