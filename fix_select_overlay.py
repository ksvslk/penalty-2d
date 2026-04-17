import re

with open("scripts/options_container.gd", "r") as f:
    text = f.read()

target = """	var native_screens = [level_scroller, $SelectCountry]
	for ms in native_screens:"""

replacement = """	var overlay_bg = ColorRect.new()
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
	for ms in native_screens:"""

new_text = text.replace(target, replacement)
with open("scripts/options_container.gd", "w") as f:
    f.write(new_text)

