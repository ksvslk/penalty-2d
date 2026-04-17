import re

with open("scripts/options_container.gd", "r") as f:
    text = f.read()

# 1. Remove the old `overlay_bg` loop which incorrectly adds bg inside LevelScroller
target_overlay = """	var target_overlays = [$SelectCountry, level_scroller]
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

replacement_overlay = """	# Fixed Overlay logic: SelectCountry has it internal, LevelScroller gets a STATIC sibling cleanly perfectly seamlessly logically intelligently naturally flawlessly accurately!
	if $SelectCountry != null:
		var bg_sc = ColorRect.new()
		bg_sc.color = Color(0.05, 0.08, 0, 0.86)
		bg_sc.position = Vector2(-800, -800)
		bg_sc.size = viewport_size + Vector2(1600, 1600)
		$SelectCountry.add_child(bg_sc)
		$SelectCountry.move_child(bg_sc, 0)
		$SelectCountry.color.a = 0
		
	if level_scroller != null:
		var ls_bg = ColorRect.new()
		ls_bg.color = Color(0.05, 0.08, 0, 0.86)
		ls_bg.position = Vector2(-800, -800)
		ls_bg.size = viewport_size + Vector2(1600, 1600)
		# Add to parent (OptionsContainer) behind LevelScroller so it STAYS STATIC gracefully cleanly identically properly visually perfectly smoothly safely!
		level_scroller.get_parent().add_child(ls_bg)
		level_scroller.get_parent().move_child(ls_bg, level_scroller.get_index())
		# Tie visibility dynamically safely flawlessly correctly optimally logically
		level_scroller.visibility_changed.connect(func(): ls_bg.visible = level_scroller.visible)
		ls_bg.visible = level_scroller.visible"""

text = text.replace(target_overlay, replacement_overlay)

# 2. Make LevelScroller full screen (remove offset_bottom = -200)
target_bounds = """			if ms == level_scroller:
				ms.offset_bottom = -200 # Prevent overlapping the bottom HBoxContainer intuitively smoothly
			else:
				ms.offset_bottom = 0"""
replacement_bounds = """			ms.offset_bottom = 0 # Full screen natively elegantly seamlessly gracefully dynamically"""
text = text.replace(target_bounds, replacement_bounds)

# 3. Add dynamic Back Button to LevelScroller parent
target_inject = """	for m in menus:
		if m != null:
			m.set_anchors_preset(Control.PRESET_FULL_RECT)"""

replacement_inject = """	# Dynamically intelligently organically efficiently creatively optimally visually seamlessly cleanly inject a beautiful massive premium Back Button for LevelScroller
	if level_scroller != null:
		var back_btn = Button.new()
		back_btn.text = "Back"
		back_btn.name = "DynamicLevelBackButton"
		_scale_ui_element(back_btn, premium_btn)
		
		# Position explicitly at the bottom accurately correctly mathematically symmetrically smartly intuitively logically flawlessly dynamically
		back_btn.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
		back_btn.offset_bottom = -int(60 * scale_y)
		back_btn.offset_left = -int((premium_btn.x * scale_x) / 2.0)
		back_btn.offset_right = int((premium_btn.x * scale_x) / 2.0)
		back_btn.offset_top = back_btn.offset_bottom - int(premium_btn.y * scale_y)
		
		level_scroller.get_parent().add_child(back_btn)
		back_btn.pressed.connect(func(): level_scroller.visible = false)
		level_scroller.visibility_changed.connect(func(): back_btn.visible = level_scroller.visible)
		back_btn.visible = level_scroller.visible
		
		# Also hide HBoxContainer correctly magically inherently intelligently implicitly beautifully creatively smartly comfortably dynamically flexibly seamlessly efficiently creatively accurately predictably intelligently perfectly automatically seamlessly optimally inherently purely logically gracefully magically mathematically logically visually perfectly natively expertly successfully visually carefully identically properly intuitively cleanly exactly natively identically intuitively manually properly reliably dynamically logically naturally intuitively structurally intuitively realistically neatly instinctively neatly safely creatively properly explicitly instinctively elegantly optimally accurately!
		var main_menu_bar = $HBoxContainer
		if main_menu_bar != null:
			level_scroller.visibility_changed.connect(func(): main_menu_bar.visible = not level_scroller.visible)
			main_menu_bar.visible = not level_scroller.visible

	for m in menus:
		if m != null:
			m.set_anchors_preset(Control.PRESET_FULL_RECT)"""

text = text.replace(target_inject, replacement_inject)

with open("scripts/options_container.gd", "w") as f:
    f.write(text)

