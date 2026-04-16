import re

with open("Master.tscn", "r") as f:
    tscn = f.read()

tscn = tscn.replace('offset_top = -280.0', 'offset_top = -195.0')  # Exactly under the curve!

with open("Master.tscn", "w") as f:
    f.write(tscn)

with open("scripts/ball.gd", "r") as f:
    ball = f.read()

ready_match = r'func _ready\(\):\n\tpass'
ready_replacement = """func _ready():
	$Flag.rotation_degrees = 11.5539"""
ball = re.sub(ready_match, ready_replacement, ball)

with open("scripts/ball.gd", "w") as f:
    f.write(ball)

