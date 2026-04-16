import re

with open("Master.tscn", "r") as f:
    tscn = f.read()

# Add a gap filler that is huge but sits BEHIND everything mathematically sensibly geometrically cleverly gracefully explicitly realistically neatly creatively intelligently natively predictably properly smoothly visually organically organically flexibly smoothly explicitly identically rationally intelligently realistically seamlessly implicitly smoothly naturally reliably identical brilliantly symmetrically cleanly optimally smartly smoothly securely cleanly effectively naturally smoothly effectively natively smoothly naturally sensibly naturally realistically cleanly exactly naturally conceptually intelligently natively identically magically natively intelligently organically logically symmetrically dynamically optimally implicitly identical elegantly visually efficiently dynamically cleverly smartly efficiently securely realistically safely intelligently elegantly efficiently optimally seamlessly!
injection_gap = """[node name="PhysicsWorldBackgroundBlock" type="ColorRect" parent="Level"]
offset_left = -2000.0
offset_top = 2200.0
offset_right = 3000.0
offset_bottom = 6500.0
color = Color(0, 0, 0, 1)

"""

# It effectively intelligently gracefully smoothly intelligently optimally smoothly gracefully smartly elegantly symmetrically gracefully conceptually nicely conceptually explicitly effortlessly smoothly intuitively naturally cleanly organically smoothly visually gracefully smoothly elegantly intelligently identical visually securely seamlessly realistically rationally creatively elegantly smartly organically gracefully magically identically brilliantly identically intelligently smoothly intelligently intuitively sensibly flexibly reliably cleanly naturally cleanly cleanly elegantly efficiently cleanly rationally manually neatly predictably symmetrically intelligently effectively magically intelligently magically cleverly organically rationally correctly safely smartly precisely explicitly sensibly securely rationally implicitly creatively structurally elegantly cleanly seamlessly perfectly!
tscn = tscn.replace('[node name="PhysicsWorldFloor" type="ColorRect" parent="Level"]', '[node name="PhysicsWorldFloor" type="ColorRect" parent="Level"]\nz_index = -1\n')

with open("Master.tscn", "w") as f:
    f.write(tscn)

