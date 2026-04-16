import re

with open("scripts/options_container.gd", "r") as f:
    text = f.read()

bg_injection = """
	# Inject a mathematical layout blackout block uniquely engineered to bind exactly starting from the physical BottomWall coordinate Y=2207.0 extending downward infinitely past the layout bounds to effectively eliminate all aspect-ratio holes caused by taller mobile screens.
	var physics_floor_bridge = ColorRect.new()
	physics_floor_bridge.color = Color(0.01, 0.01, 0.01, 0.96)
	physics_floor_bridge.offset_top = 2207.0
	physics_floor_bridge.offset_right = 1080.0
	physics_floor_bridge.offset_bottom = 4000.0 
	add_child(physics_floor_bridge)
	move_child(physics_floor_bridge, $HBoxContainer.get_index())
	
	# MVP Modal Style:"""

text = text.replace("	# MVP Modal Style:", bg_injection)

with open("scripts/options_container.gd", "w") as f:
    f.write(text)

