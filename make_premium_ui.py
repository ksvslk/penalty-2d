import re

# -------------
# Options Container Refactor
# -------------
with open("scripts/options_container.gd", "r") as f:
    text = f.read()

# Make the helper inject a premium StyleBoxFlat instead of stripping!
new_helper = """
func _scale_ui_element(node: Node, primary_style: StyleBoxFlat):
	if node is Button:
		node.add_theme_font_size_override("font_size", 48)
		# Add our luxurious premium padding and background style
		node.add_theme_stylebox_override("normal", primary_style)
		node.add_theme_stylebox_override("hover", primary_style)
		node.add_theme_stylebox_override("pressed", primary_style)
		
		# Enforce massive luxury widths
		if not node.get_parent() is HBoxContainer:
			node.custom_minimum_size = Vector2(900, 140)
		else:
			node.custom_minimum_size = Vector2(430, 140) 
			
	elif node is Label:
		node.add_theme_font_size_override("font_size", 56)
		
	# Recurse children
	for child in node.get_children():
		_scale_ui_element(child, primary_style)

"""
text = re.sub(r'func _scale_ui_element\(node: Node\):.*?for child in node\.get_children\(\):\n\t\t_scale_ui_element\(child\)\n', new_helper, text, flags=re.DOTALL)

# Inject the style initialization into _ready
style_init = """	
	var premium_btn = StyleBoxFlat.new()
	premium_btn.bg_color = Color(0.12, 0.12, 0.12, 1.0)
	premium_btn.corner_radius_top_left = 15
	premium_btn.corner_radius_top_right = 15
	premium_btn.corner_radius_bottom_left = 15
	premium_btn.corner_radius_bottom_right = 15
	premium_btn.content_margin_left = 40
	premium_btn.content_margin_right = 40
	premium_btn.content_margin_top = 20
	premium_btn.content_margin_bottom = 20
	
	# MVP Modal Style:"""

text = text.replace("	# MVP Modal Style:", style_init)

# Replace the inner_box separation from 20 -> 40
text = text.replace('inner_box.add_theme_constant_override("separation", 20)', 'inner_box.add_theme_constant_override("separation", 40)')

# Update the recursive call
text = text.replace('_scale_ui_element(child)', '_scale_ui_element(child, premium_btn)')

# Update the local BACK button
back_btn_old = """			var local_back = Button.new()
			local_back.text = "BACK"
			local_back.custom_minimum_size = Vector2(800, 120)
			local_back.add_theme_font_size_override("font_size", 48)
"""
back_btn_new = """			var local_back = Button.new()
			local_back.text = "BACK"
			local_back.custom_minimum_size = Vector2(900, 140)
			local_back.add_theme_font_size_override("font_size", 48)
			local_back.add_theme_stylebox_override("normal", premium_btn)
			local_back.add_theme_stylebox_override("hover", premium_btn)
			local_back.add_theme_stylebox_override("pressed", premium_btn)
"""
text = text.replace(back_btn_old, back_btn_new)

# Bring back a bit of translucency! 1.0 -> 0.95
text = text.replace('Color(0.05, 0.05, 0.05, 1.0)', 'Color(0.05, 0.05, 0.05, 0.96)')

with open("scripts/options_container.gd", "w") as f:
    f.write(text)


# -------------
# Multiplayer UI Refactor
# -------------
with open("scripts/multiplayer_ui.gd", "r") as f:
    text2 = f.read()

text2 = text2.replace('inner_box.add_theme_constant_override("separation", 20)', 'inner_box.add_theme_constant_override("separation", 40)')
text2 = text2.replace('main_container.add_theme_constant_override("separation", 20)', 'main_container.add_theme_constant_override("separation", 40)')

text2 = text2.replace('Color(0.05, 0.05, 0.05, 1.0)', 'Color(0.05, 0.05, 0.05, 0.96)')

# Update the button creator to apply premium style
old_btn = """func _create_button(text: String) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(800, 120)
	btn.add_theme_font_size_override("font_size", 48)
	return btn"""

new_btn = """func _create_button(text: String) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(900, 140)
	btn.add_theme_font_size_override("font_size", 48)
	
	var premium_btn = StyleBoxFlat.new()
	premium_btn.bg_color = Color(0.12, 0.12, 0.12, 1.0)
	premium_btn.corner_radius_top_left = 15
	premium_btn.corner_radius_top_right = 15
	premium_btn.corner_radius_bottom_left = 15
	premium_btn.corner_radius_bottom_right = 15
	premium_btn.content_margin_left = 40
	premium_btn.content_margin_right = 40
	premium_btn.content_margin_top = 20
	premium_btn.content_margin_bottom = 20
	
	btn.add_theme_stylebox_override("normal", premium_btn)
	btn.add_theme_stylebox_override("hover", premium_btn)
	btn.add_theme_stylebox_override("pressed", premium_btn)
	
	return btn"""
text2 = text2.replace(old_btn, new_btn)

# Make JOIN button share the rest of the space nicely
text2 = text2.replace('Vector2(450, 120)', 'Vector2(550, 140)')
text2 = text2.replace('Vector2(300, 120)', 'Vector2(320, 140)')

with open("scripts/multiplayer_ui.gd", "w") as f:
    f.write(text2)

