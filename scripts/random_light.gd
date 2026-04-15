# In Godot 4, Light2D has been replaced by more specific nodes.
# PointLight2D is the correct choice for a positional light source.
extends PointLight2D

var random_position := Vector2.ZERO
var current_target_destination := Vector2.ZERO
@export var speed := 2.0


func _process(delta: float) -> void:
	# The original script had unused 'move_toward' calls here.
	# The intended movement is a smooth interpolation (lerp) towards the target.
	# The Vector2.lerp() method is a clean way to write this.
	global_position = global_position.lerp(current_target_destination, delta * speed)


func appear() -> void:
	# Godot 4 Tween API
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	
	# Animate the alpha component of the light's color to fade it in.
	tween.tween_property(self, "color:a", 1.0, 2.0)
	
	# Call the 'light_on' function on the parent node when the tween finishes.
	tween.tween_callback(get_parent().light_on)


func disappear() -> void:
	# Godot 4 Tween API
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)
	
	# Animate the alpha component of the light's color to fade it out.
	tween.tween_property(self, "color:a", 0.0, 1.5)
	
	# Call the 'light_off' function on the parent node when the tween finishes.
	tween.tween_callback(get_parent().light_off)
