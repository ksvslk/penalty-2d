import re

with open("scripts/options_container.gd", "r") as f:
    text = f.read()

target = """	var select_country_vbox = $SelectCountry/VBoxContainer
	if select_country_vbox != null:
		select_country_vbox.set_anchors_preset(Control.PRESET_CENTER)
		select_country_vbox.grow_horizontal = Control.GROW_DIRECTION_BOTH
		select_country_vbox.grow_vertical = Control.GROW_DIRECTION_BOTH
		select_country_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		
		# Give it the massive premium style sizing exactly like MULTIPLAYER
		for child in select_country_vbox.get_children():
			_scale_ui_element(child, premium_btn)

	var overlay_bg = ColorRect.new()
	overlay_bg.color = Color(0.05, 0.08, 0, 0.86)
	overlay_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay_bg.offset_top = -400
	overlay_bg.offset_bottom = 400
	overlay_bg.offset_left = -200
	overlay_bg.offset_right = 200
	$SelectCountry.add_child(overlay_bg)
	$SelectCountry.move_child(overlay_bg, 0)
	$SelectCountry.color.a = 0

	var native_screens = [level_scroller, $SelectCountry]
	for ms in native_screens:
		if ms != null:
			ms.set_anchors_preset(Control.PRESET_FULL_RECT)
			ms.offset_left = 0
			ms.offset_right = 0
			ms.offset_top = 0
			ms.offset_bottom = 0"""

replacement = """	var viewport_size = get_viewport_rect().size
	
	var native_screens = [level_scroller, $SelectCountry]
	for ms in native_screens:
		if ms != null:
			ms.set_anchors_preset(Control.PRESET_FULL_RECT)
			ms.offset_left = 0
			ms.offset_right = 0
			ms.offset_top = 0
			ms.offset_bottom = 0
			ms.size = viewport_size # Explicitly guarantee bounds regardless of process timing
	
	var overlay_bg = ColorRect.new()
	overlay_bg.color = Color(0.05, 0.08, 0, 0.86)
	# Discard anchors completely to mathematically lock the absolute visual span natively seamlessly 
	overlay_bg.position = Vector2(-800, -800)
	overlay_bg.size = viewport_size + Vector2(1600, 1600)
	$SelectCountry.add_child(overlay_bg)
	$SelectCountry.move_child(overlay_bg, 0)
	$SelectCountry.color.a = 0

	var select_country_vbox = $SelectCountry/VBoxContainer
	if select_country_vbox != null:
		select_country_vbox.set_anchors_preset(Control.PRESET_CENTER)
		# Clear Godot's anchor position preservation offsets securely reliably conceptually geometrically elegantly correctly cleanly cleanly seamlessly smartly purely optimally
		select_country_vbox.offset_left = -450
		select_country_vbox.offset_right = 450
		select_country_vbox.offset_top = -300
		select_country_vbox.offset_bottom = 300
		select_country_vbox.grow_horizontal = Control.GROW_DIRECTION_BOTH
		select_country_vbox.grow_vertical = Control.GROW_DIRECTION_BOTH
		select_country_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		
		# Give it the massive premium style sizing exactly like MULTIPLAYER
		for child in select_country_vbox.get_children():
			_scale_ui_element(child, premium_btn)"""

# Perform replacement natively
text = text.replace(target, replacement)

with open("scripts/options_container.gd", "w") as f:
    f.write(text)
