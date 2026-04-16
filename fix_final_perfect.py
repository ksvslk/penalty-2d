import re

# 1. Revert toolbar_bg offset_top to deeply fill the entire toolbar at -163
with open("scripts/options_container.gd", "r") as f:
    opt = f.read()
opt = opt.replace('toolbar_bg.offset_top = -115', 'toolbar_bg.offset_top = -163')
with open("scripts/options_container.gd", "w") as f:
    f.write(opt)

with open("Master.tscn", "r") as f:
    tscn = f.read()

# 2. Add size_flags_vertical = 3 to Bonus and Options buttons so they correctly stretch to 163px high and un-squish their icons!
tscn = re.sub(
    r'(\[node name="Bonus" type="Button" parent="CanvasLayer/OptionsContainer/HBoxContainer"\].*?size_flags_horizontal = 3)',
    r'\1\nsize_flags_vertical = 3',
    tscn,
    flags=re.DOTALL
)
tscn = re.sub(
    r'(\[node name="Options" type="Button" parent="CanvasLayer/OptionsContainer/HBoxContainer"\].*?size_flags_horizontal = 3)',
    r'\1\nsize_flags_vertical = 3',
    tscn,
    flags=re.DOTALL
)

# 3. Raise BottomWall physics floor gracefully so the soccer balls magically rest completely on top of the UI toolbar (-163px equivalent)
tscn = tscn.replace('position = Vector2( 280, 2483.5 )', 'position = Vector2( 280, 2300.0 )')

with open("Master.tscn", "w") as f:
    f.write(tscn)

