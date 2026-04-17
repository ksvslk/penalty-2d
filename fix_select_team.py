import re

with open("scripts/options_container.gd", "r") as f:
    text = f.read()

# I will add a dynamic layout enforcement for SelectCountry's VBoxContainer
target_str = """	var native_screens = [level_scroller, $SelectCountry]
	for ms in native_screens:"""

replacement_str = """	# Mathematically perfectly intuitively brilliantly seamlessly intelligently configure SelectCountry elements
	var select_country_vbox = $SelectCountry/VBoxContainer
	if select_country_vbox != null:
		select_country_vbox.set_anchors_preset(Control.PRESET_CENTER)
		select_country_vbox.grow_horizontal = Control.GROW_DIRECTION_BOTH
		select_country_vbox.grow_vertical = Control.GROW_DIRECTION_BOTH
		select_country_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		
		# Give it the massive premium style sizing exactly like MULTIPLAYER
		for child in select_country_vbox.get_children():
			_scale_ui_element(child, premium_btn)

	var native_screens = [level_scroller, $SelectCountry]
	for ms in native_screens:"""

text = text.replace(target_str, replacement_str)

with open("scripts/options_container.gd", "w") as f:
    f.write(text)

