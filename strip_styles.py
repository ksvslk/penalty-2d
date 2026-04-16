with open("scripts/options_container.gd", "r") as f:
    text = f.read()

target = """	if node is Button:
		node.add_theme_font_size_override("font_size", 48)"""

replacement = """	if node is Button:
		node.add_theme_font_size_override("font_size", 48)
		# Strip the pure black legacy SubResource overrides so they match the standard Godot Button aesthetic used perfectly by the PVP menu!
		for state in ["normal", "hover", "pressed", "disabled", "focus"]:
			if node.has_theme_stylebox_override(state):
				node.remove_theme_stylebox_override(state)
"""

text = text.replace(target, replacement)

with open("scripts/options_container.gd", "w") as f:
    f.write(text)

