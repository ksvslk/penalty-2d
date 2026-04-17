import re

with open("scripts/options_container.gd", "r") as f:
    code = f.read()

replacement = """	var menus = [play_games_list, bonus_list, options_list]
	for m in menus:
		if m != null:
			m.set_anchors_preset(Control.PRESET_FULL_RECT)"""

new_code = """	var menus = [play_games_list, bonus_list, options_list]
	var native_screens = [level_scroller, $SelectCountry]
	for ms in native_screens:
		if ms != null:
			ms.set_anchors_preset(Control.PRESET_FULL_RECT)
			ms.offset_left = 0
			ms.offset_right = 0
			ms.offset_top = 0
			ms.offset_bottom = 0

	for m in menus:
		if m != null:
			m.set_anchors_preset(Control.PRESET_FULL_RECT)"""

code = code.replace(replacement, new_code)

with open("scripts/options_container.gd", "w") as f:
    f.write(code)

