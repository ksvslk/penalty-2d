import re

with open("scripts/ball.gd", "r") as f:
    ball = f.read()

# Replace _ready() safely
ready_match = r'func _ready\(\):\n\t# The \S+ property was removed in Godot 4\.\n\t# Material inheritance.*?\n\tpass'
ready_replacement = """func _ready():
	$Flag.set_as_top_level(true)
	$FlagBackground.set_as_top_level(true)"""
ball = re.sub(ready_match, ready_replacement, ball, flags=re.DOTALL)

# Replace _process() safely
process_match = r'func _process\(delta\):\n\tif held:\n\t\tmediator\.add_swish\(name, \[global_position, get_global_mouse_position\(\)\]\)'
process_replacement = """func _process(delta):
	$Flag.global_position = global_position + Vector2(-11, -55)
	$FlagBackground.global_position = global_position + Vector2(11, -27)
	if held:
		mediator.add_swish(name, [global_position, get_global_mouse_position()])"""
ball = re.sub(process_match, process_replacement, ball, flags=re.DOTALL)

with open("scripts/ball.gd", "w") as f:
    f.write(ball)

