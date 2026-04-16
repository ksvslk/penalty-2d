import re

with open("scripts/options_container.gd", "r") as f:
    text = f.read()

bg_injection = """
	# Inject a deep pure black backdrop behind the bottom row toolbar natively so the "weird grey" gaps are flawlessly patched
	var toolbar_bg = ColorRect.new()
	toolbar_bg.color = Color(0.01, 0.01, 0.01, 0.96)
	toolbar_bg.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	toolbar_bg.offset_top = -300
	toolbar_bg.offset_bottom = 100
	add_child(toolbar_bg)
	move_child(toolbar_bg, $HBoxContainer.get_index())
	
	# MVP Modal Style:"""

text = text.replace("	# MVP Modal Style:", bg_injection)

with open("scripts/options_container.gd", "w") as f:
    f.write(text)

