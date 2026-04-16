import re

with open("scripts/options_container.gd", "r") as f:
    text = f.read()

helper = """
func _scale_ui_element(node: Node):
	if node is Button:
		node.add_theme_font_size_override("font_size", 48)
		# Only enforce massive width if it is not inside an HBoxContainer
		if not node.get_parent() is HBoxContainer:
			node.custom_minimum_size = Vector2(800, 120)
		else:
			node.custom_minimum_size = Vector2(380, 120) # Fit nicely side-by-side
	elif node is Label:
		node.add_theme_font_size_override("font_size", 48)
		
	# Recurse children
	for child in node.get_children():
		_scale_ui_element(child)

"""

text = text.replace("func _ready():", helper + "func _ready():")

# Replace the simplistic child scaling loop
old_loop = """				if child is Button:
					child.custom_minimum_size = Vector2(800, 120)
					child.add_theme_font_size_override("font_size", 48)"""

new_loop = """				_scale_ui_element(child)"""

text = text.replace(old_loop, new_loop)

with open("scripts/options_container.gd", "w") as f:
    f.write(text)

