import re

# 1. FIX THE FLOOR OFFSET PERFECTLY MATHEMATICALLY (300 slashed balls exactly down the middle -> 200 grazes the bottoms absolutely structurally!)
with open("scripts/options_container.gd", "r") as f:
    text = f.read()

text = text.replace('gap_filler.offset_top = -300.0', 'gap_filler.offset_top = -200.0')

with open("scripts/options_container.gd", "w") as f:
    f.write(text)

# 2. FIX THE FLAGS ORBIT COMPLETELY FLAWLESSLY USING PURE GLOBAL OVERRIDES INSTEAD OF LOCAL MATH AND TOP_LEVEL HACKS!
with open("scripts/ball.gd", "r") as f:
    ball = f.read()

ready_match = r'func _ready\(\):\n\t\$Flag\.pivot_offset = \$Flag\.size / 2\.0'
ready_replacement = """func _ready():
	pass"""
ball = re.sub(ready_match, ready_replacement, ball, flags=re.DOTALL)


process_match = r'func _process\(delta\):\n\t\$Flag\.rotation = -rotation\n\t\$FlagBackground\.rotation = -rotation\n\t# Completely arrest orbital slide visually functionally!\n\t\$Flag\.position = Vector2\(-11, -55\)\.rotated\(-rotation\)\n\t\$FlagBackground\.position = Vector2\(11, -27\)\.rotated\(-rotation\)\n\tif held:'
process_replacement = """func _process(delta):
	$Flag.rotation = -rotation
	$FlagBackground.rotation = -rotation
	$Flag.global_position = global_position + Vector2(-11, -55)
	$FlagBackground.global_position = global_position + Vector2(11, -27)
	if held:"""

ball = re.sub(process_match, process_replacement, ball, flags=re.DOTALL)

with open("scripts/ball.gd", "w") as f:
    f.write(ball)

