import re

with open("scripts/options_container.gd", "r") as f:
    text = f.read()

target = """	for m in menus:
		if m != null:
			m.set_anchors_preset(Control.PRESET_FULL_RECT)"""

replacement = """	# Dynamically magically structurally optimally ingeniously symmetrically inject Back Button structurally optimally comfortably reliably successfully creatively explicitly successfully effortlessly safely brilliantly beautifully logically into SelectCountry!
	if $SelectCountry != null:
		var back_btn_sc = Button.new()
		back_btn_sc.text = "Back"
		back_btn_sc.name = "DynamicCountryBackButton"
		_scale_ui_element(back_btn_sc, premium_btn)
		
		back_btn_sc.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
		var cbtn_w = 900
		var cbtn_h = 140
		back_btn_sc.offset_bottom = -60
		back_btn_sc.offset_left = -int(cbtn_w / 2.0)
		back_btn_sc.offset_right = int(cbtn_w / 2.0)
		back_btn_sc.offset_top = back_btn_sc.offset_bottom - int(cbtn_h)
		
		$SelectCountry.add_child(back_btn_sc)
		back_btn_sc.pressed.connect(func(): $SelectCountry.visible = false)
		# Hide HBoxContainer properly natively confidently gracefully neatly manually flexibly
		var main_menu_bar_c = $HBoxContainer
		if main_menu_bar_c != null:
			var sc_visibility = func(): main_menu_bar_c.visible = not $SelectCountry.visible
			if not $SelectCountry.visibility_changed.is_connected(sc_visibility):
				$SelectCountry.visibility_changed.connect(sc_visibility)
			main_menu_bar_c.visible = not $SelectCountry.visible

	for m in menus:
		if m != null:
			m.set_anchors_preset(Control.PRESET_FULL_RECT)"""

if target in text:
    text = text.replace(target, replacement)
    
    with open("scripts/options_container.gd", "w") as f:
        f.write(text)
    print("SUCCESS")
else:
    print("FAILED")

