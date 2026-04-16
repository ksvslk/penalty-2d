import re

with open("Master.tscn", "r") as f:
    tscn = f.read()

# 1. FIX THE FLOOR: Correctly inject FloorBlackout exactly where it belongs in the Level hierarchy!
injection = """[node name="FloorBlackout" type="ColorRect" parent="Level"]
offset_top = 2307.0
offset_right = 1080.0
offset_bottom = 4000.0
color = Color( 0, 0, 0, 1 )

[node name="Walls" type="StaticBody2D" parent="Level"]"""

tscn = tscn.replace('[node name="Walls" type="StaticBody2D" parent="Level"]', injection)

with open("Master.tscn", "w") as f:
    f.write(tscn)


# 2. FIX THE FLAGS: Completely break them physically isolated from the RigidBody2D rotation and bind them linearly to global_position!
with open("scripts/ball.gd", "r") as f:
    ball = f.read()

ready_injection = """func _ready():
	$Flag.set_as_top_level(true)
	$FlagBackground.set_as_top_level(true)"""

process_injection = """func _process(delta):
	$Flag.global_position = global_position + Vector2(-11, -55)
	$FlagBackground.global_position = global_position + Vector2(11, -27)
	if held:"""

# Remove old broken process
ball = re.sub(r'\$Flag\.rotation = 0\.201653 - rotation.*?if held:', 'if held:', ball, flags=re.DOTALL)
# Inject new Process
ball = ball.replace('if held:', process_injection)
# Inject new Ready
ball = ball.replace('func _ready():', ready_injection)

with open("scripts/ball.gd", "w") as f:
    f.write(ball)

