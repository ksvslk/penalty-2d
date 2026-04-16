import re

with open("scripts/options_container.gd", "r") as f:
    text = f.read()

# Completely Strip out the dynamic injected logic! It's better mathematically inside the exact physics Scene tree!
text = re.sub(r'# Inject a mathematical layout blackout block uniquely engineered to bind exactly starting from the physical BottomWall coordinate Y=2207\.0.*?10$', '', text, flags=re.DOTALL | re.MULTILINE)

# Remove the specific physics floor bridge code we just added
clean_lines = []
skip = False
for line in text.split('\n'):
    if "var physics_floor_bridge = ColorRect.new()" in line:
        skip = True
    if skip and "move_child(physics_floor_bridge" in line:
        skip = False
        continue
    if not skip:
        clean_lines.append(line)

with open("scripts/options_container.gd", "w") as f:
    f.write("\n".join(clean_lines))

with open("Master.tscn", "r") as f:
    tscn = f.read()

# Inject the FloorBlackout perfectly into the Level Node
injection = """[node name="Walls" type="Node2D" parent="Level"]

[node name="FloorBlackout" type="ColorRect" parent="Level"]
offset_top = 2307.0
offset_right = 1080.0
offset_bottom = 4000.0
color = Color( 0, 0, 0, 1 )"""

tscn = tscn.replace('[node name="Walls" type="Node2D" parent="Level"]', injection)

with open("Master.tscn", "w") as f:
    f.write(tscn)

