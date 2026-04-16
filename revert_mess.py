import re

# Remove the dynamic black background entirely
with open("scripts/options_container.gd", "r") as f:
    text = f.read()

new_text = []
for line in text.split("\n"):
    if "toolbar_bg" in line:
        continue
    new_text.append(line)

with open("scripts/options_container.gd", "w") as f:
    f.write("\n".join(new_text))

# Revert BottomWall to its original perfect physics floor
with open("Master.tscn", "r") as f:
    tscn = f.read()
tscn = tscn.replace('position = Vector2( 280, 2300.0 )', 'position = Vector2( 280, 2483.5 )')

# Remove the HBOX separation so the buttons merge securely without needing a hacky background
tscn = tscn.replace('theme_override_constants/h_separation = 20', 'theme_override_constants/h_separation = 0')

with open("Master.tscn", "w") as f:
    f.write(tscn)

# Fix the ball flag rotation locking natively during _process
with open("scripts/ball.gd", "r") as f:
    ball = f.read()

rot_injection = """func _process(delta):
	$Flag.global_rotation = 0
	$FlagBackground.global_rotation = 0
	if held:"""

ball = ball.replace("""func _process(delta):
	if held:""", rot_injection)

# Wait! FlagBackground has a native rotational offset, it's not rotated zero!
# Flag rect_rotation = 11.5539
# FlagBackground rotation = 0.201653 (which is 11.55 deg)
# So global_rotation = 0.201653 !
ball = ball.replace('$Flag.global_rotation = 0', '$Flag.global_rotation = 0.201653')
ball = ball.replace('$FlagBackground.global_rotation = 0', '$FlagBackground.global_rotation = 0.201653')

with open("scripts/ball.gd", "w") as f:
    f.write(ball)

