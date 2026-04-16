import re

with open("scripts/options_container.gd", "r") as f:
    text = f.read()

# 1. Make the floor completely securely opaque! (no 0.96 translucency!)
# 2. Lower it exactly by exactly one ball radius mathematically (100 pixels) from 2207.0 down to 2307.0 so it perfectly and gently grazes the exact visual bottom rim of the soccer ball instead of severing calculating centers!
text = text.replace('physics_floor_bridge.color = Color(0.01, 0.01, 0.01, 0.96)', 'physics_floor_bridge.color = Color(0.0, 0.0, 0.0, 1.0)')
text = text.replace('physics_floor_bridge.offset_top = 2207.0', 'physics_floor_bridge.offset_top = 2307.0')

with open("scripts/options_container.gd", "w") as f:
    f.write(text)
