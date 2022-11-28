extends Label

onready var timer = $Timer
onready var original_start_time = start_time
export var start_time := 10
onready var tick_sound = $TickSound
onready var tock_sound = $TockSound

var tick = true

signal round_done

func _ready():
	modulate = Color.green
	text = str(start_time)


func get_seconds_passed() -> int:
	return original_start_time - start_time


func _on_Timer_timeout():
	if start_time >= 1:
		start_time -= 1
		if start_time < 16:
			if tick:
				tick_sound.play()
			else:
				tock_sound.play()
			tick = !tick
			modulate = Color.red
		text = str(start_time)
		timer.start()
	else:
		emit_signal("round_done")
		timer.stop()


func restart_timer_for_next_round():
	modulate = Color.green
	start_time = original_start_time
	text = str(start_time)
	timer.start()
