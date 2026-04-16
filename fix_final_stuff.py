import re

# 1. Update Gear SVG to pure white!
with open("art/gear.svg", "r") as f:
    svg = f.read()

svg = svg.replace("fill:#949096", "fill:#ffffff")
svg = svg.replace("stroke:#2c2c2c", "stroke:#ececec")

with open("art/gear.svg", "w") as f:
    f.write(svg)


# 2. Fix colors in options_container
with open("scripts/options_container.gd", "r") as f:
    opt = f.read()

# Change the premium button background to pure pitch black to match the bottom menu exactly
opt = opt.replace("premium_btn.bg_color = Color(0.12, 0.12, 0.12, 1.0)", "premium_btn.bg_color = Color(0.01, 0.01, 0.01, 0.96)")

with open("scripts/options_container.gd", "w") as f:
    f.write(opt)


# 3. Fix colors and "Select Mode" in multiplayer_ui
with open("scripts/multiplayer_ui.gd", "r") as f:
    mp = f.read()

mp = mp.replace("premium_btn.bg_color = Color(0.12, 0.12, 0.12, 1.0)", "premium_btn.bg_color = Color(0.01, 0.01, 0.01, 0.96)")

# Fix "Select Mode" label
old_status = """	status_label = Label.new()
	status_label.text = "Select Mode"
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_container.add_child(status_label)"""

new_status = """	status_label = Label.new()
	status_label.text = "Select Mode"
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.add_theme_font_size_override("font_size", 32)
	main_container.add_child(status_label)"""

mp = mp.replace(old_status, new_status)

with open("scripts/multiplayer_ui.gd", "w") as f:
    f.write(mp)

