import re

with open("scripts/options_container.gd", "r") as f:
    text = f.read()

# Fix the massive black block overlapping the soccer balls!
text = text.replace('toolbar_bg.offset_top = -300', 'toolbar_bg.offset_top = -163')

with open("scripts/options_container.gd", "w") as f:
    f.write(text)

with open("Master.tscn", "r") as f:
    tscn = f.read()

# Fix the incredibly thin Options button stretch ratio which was squashing the gear icon!
# Look for Options button specifically
tscn = re.sub(
    r'(\[node name="Options" type="Button" parent="CanvasLayer/OptionsContainer/HBoxContainer"\].*?size_flags_stretch_ratio = )0\.2',
    r'\g<1>0.35',
    tscn,
    flags=re.DOTALL
)

with open("Master.tscn", "w") as f:
    f.write(tscn)

