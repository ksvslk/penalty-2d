extends ColorRect

onready var label = $Label
onready var timer = $Timer
var count = 3

func _set(property, value):
	if property == "visible":
		if value:
			count = 3
			label.text = "Commercial break."
			timer.start()


func _on_Timer_timeout():
	count -= 1
	if count == 0:
		count = 3
		timer.stop()
		GPack.show_interstitial_ad()
		visible = false
	else:
		label.text += "."
		timer.start()
