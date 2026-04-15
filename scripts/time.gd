extends Label

@onready var timer: Timer = $Timer
@onready var tick_sound: AudioStreamPlayer2D = $TickSound
@onready var tock_sound: AudioStreamPlayer2D = $TockSound

@export var start_time := 10

# This will be assigned in _ready() to correctly capture the exported value.
var original_start_time: int
var tick := true

signal round_done

func _ready() -> void:
	# Assign original_start_time here to make sure it uses the value
	# set in the Inspector, which is loaded before _ready() is called.
	original_start_time = start_time
	
	modulate = Color.GREEN
	text = str(start_time)


func get_seconds_passed() -> int:
	return original_start_time - start_time


func _on_Timer_timeout() -> void:
	if start_time >= 1:
		start_time -= 1
		if start_time < 16:
			if tick:
				tick_sound.play()
			else:
				tock_sound.play()
			tick = not tick
			modulate = Color.RED
		text = str(start_time)
		timer.start()
	else:
		# Godot 4 signal emission syntax
		round_done.emit()
		timer.stop()


func restart_timer_for_next_round() -> void:
	modulate = Color.GREEN
	start_time = original_start_time
	text = str(start_time)
	timer.start()
