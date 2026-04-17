import re

with open("scripts/options_container.gd", "r") as f:
    text = f.read()

target = """	var overlay_bg = ColorRect.new()
	overlay_bg.color = Color(0.05, 0.08, 0, 0.86)
	# Discard anchors completely to mathematically lock the absolute visual span natively seamlessly 
	overlay_bg.position = Vector2(-800, -800)
	overlay_bg.size = viewport_size + Vector2(1600, 1600)
	$SelectCountry.add_child(overlay_bg)
	$SelectCountry.move_child(overlay_bg, 0)
	$SelectCountry.color.a = 0"""

replacement = """	var target_overlays = [$SelectCountry, level_scroller]
	for target_ms in target_overlays:
		if target_ms != null:
			var bg = ColorRect.new()
			bg.color = Color(0.05, 0.08, 0, 0.86)
			bg.position = Vector2(-800, -800)
			bg.size = viewport_size + Vector2(1600, 1600)
			target_ms.add_child(bg)
			target_ms.move_child(bg, 0)
			if "color" in target_ms:
				target_ms.color.a = 0"""

text = text.replace(target, replacement)

with open("scripts/options_container.gd", "w") as f:
    f.write(text)

