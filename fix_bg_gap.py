import re

with open("Master.tscn", "r") as f:
    text = f.read()

# Stretch background to full 2400 to cover any awkward gaps before the bottom menu
text = text.replace('offset_bottom = 2207.0\nmouse_filter = 2\ntexture = ExtResource( 2 )', 'offset_bottom = 2400.0\nmouse_filter = 2\ntexture = ExtResource( 2 )')

# Make the settings gear icon visually expand so it isn't tiny
text = text.replace('[node name="Options" type="Button" parent="CanvasLayer/OptionsContainer/HBoxContainer"]\nmouse_filter = 1', '[node name="Options" type="Button" parent="CanvasLayer/OptionsContainer/HBoxContainer"]\nmouse_filter = 1\nicon_alignment = 1\nexpand_icon = true')

with open("Master.tscn", "w") as f:
    f.write(text)

