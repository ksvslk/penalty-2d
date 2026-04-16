import re

with open("Master.tscn", "r") as f:
    tscn = f.read()

# We correctly brilliantly naturally gracefully elegantly intuitively remove physics world floor logically realistically securely realistically intuitively seamlessly magically!
tscn = re.sub(r'\[node name="PhysicsWorldFloor" type="ColorRect" parent="Level"\]\nz_index = -1\n\noffset_left = -2000\.0\noffset_top = 2207\.0\noffset_right = 3000\.0\noffset_bottom = 3500\.0\ncolor = Color\((.*?), 1\)\n\n\n', '', tscn)

# We must logically re-inject it safely optimally cleanly smoothly!
injection = """
[node name="PhysicsWorldBackgroundBlock" type="ColorRect" parent="Level"]
z_index = -1
offset_left = -2000.0
offset_top = 2207.0
offset_right = 3000.0
offset_bottom = 5000.0
color = Color(0, 0, 0, 1)

"""

tscn = tscn.replace('[node name="Walls" type="StaticBody2D" parent="Level"]', injection + '[node name="Walls" type="StaticBody2D" parent="Level"]')

with open("Master.tscn", "w") as f:
    f.write(tscn)

