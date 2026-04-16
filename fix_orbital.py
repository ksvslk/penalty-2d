import re

with open("scripts/ball.gd", "r") as f:
    ball = f.read()

# Fix orbital sliding mathematically exactly dynamically mapping visual overrides purely seamlessly around center root regardless of physical spin constraints!
process_match = r'func _process\(delta\):\n\t\$Flag\.rotation = 0\.201653 - rotation\n\t\$FlagBackground\.rotation = 0\.201653 - rotation\n\tif held:'
process_replacement = """func _process(delta):
	$Flag.rotation = -rotation
	$FlagBackground.rotation = -rotation
	# Completely arrest orbital slide visually functionally!
	$Flag.position = Vector2(-11, -55).rotated(-rotation)
	$FlagBackground.position = Vector2(11, -27).rotated(-rotation)
	if held:"""
ball = re.sub(process_match, process_replacement, ball, flags=re.DOTALL)

with open("scripts/ball.gd", "w") as f:
    f.write(ball)

