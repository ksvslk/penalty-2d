import re

# 1. Strip the silent-failing ColorRect from Master.tscn and inject a bulletproof Polygon2D!
with open("Master.tscn", "r") as f:
    tscn = f.read()

tscn = re.sub(r'\[node name="FloorBlackout" type="ColorRect" parent="Level"\].*?color = Color\( 0, 0, 0, 1 \)\n\n', '', tscn, flags=re.DOTALL)

injection = """[node name="FloorBlackout" type="Polygon2D" parent="Level"]
color = Color( 0, 0, 0, 1 )
polygon = PoolVector2Array( -500, 2307, 2000, 2307, 2000, 5000, -500, 5000 )

[node name="Walls" type="StaticBody2D" parent="Level"]"""

tscn = tscn.replace('[node name="Walls" type="StaticBody2D" parent="Level"]', injection)

with open("Master.tscn", "w") as f:
    f.write(tscn)

# 2. Fix the ball script by restoring traditional rotation and pivoting cleanly
with open("scripts/ball.gd", "r") as f:
    ball = f.read()

# Replace _ready() safely
ready_match = r'func _ready\(\):\n\t\$Flag\.set_as_top_level\(true\)\n\t\$FlagBackground\.set_as_top_level\(true\)'
ready_replacement = """func _ready():
	$Flag.pivot_offset = $Flag.size / 2.0"""
ball = re.sub(ready_match, ready_replacement, ball, flags=re.DOTALL)

# Replace _process() safely
process_match = r'func _process\(delta\):\n\t\$Flag\.global_position = global_position \+ Vector2\(-11, -55\)\n\t\$FlagBackground\.global_position = global_position \+ Vector2\(11, -27\)\n\tif held:'
process_replacement = """func _process(delta):
	$Flag.rotation = 0.201653 - rotation
	$FlagBackground.rotation = 0.201653 - rotation
	if held:"""
ball = re.sub(process_match, process_replacement, ball, flags=re.DOTALL)

with open("scripts/ball.gd", "w") as f:
    f.write(ball)

