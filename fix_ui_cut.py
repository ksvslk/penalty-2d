import re

with open("scripts/options_container.gd", "r") as f:
    text = f.read()

# Lower the black block so it rests identically below the balls again
text = text.replace('toolbar_bg.offset_top = -163', 'toolbar_bg.offset_top = -115')

with open("scripts/options_container.gd", "w") as f:
    f.write(text)

with open("Master.tscn", "r") as f:
    tscn = f.read()

# Maximize Settings icon ratio exactly to match PVP width identically!
tscn = re.sub(
    r'(\[node name="Options" type="Button" parent="CanvasLayer/OptionsContainer/HBoxContainer"\].*?size_flags_stretch_ratio = )0\.35',
    r'\g<1>0.5',
    tscn,
    flags=re.DOTALL
)

with open("Master.tscn", "w") as f:
    f.write(tscn)

