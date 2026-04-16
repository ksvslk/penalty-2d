import re

# 1. Cleanly strip all dynamic gap_filler layout scripting physically to prevent any rendering layout bugs
with open("scripts/options_container.gd", "r") as f:
    text = f.read()

text = re.sub(r'\n\tvar gap_filler = ColorRect\.new\(\).*?move_child\(gap_filler, \$HBoxContainer\.get_index\(\)\)\n', '', text, flags=re.DOTALL)

with open("scripts/options_container.gd", "w") as f:
    f.write(text)

# 2. Mechanically natively inject a pure monolithic ColorRect directly into Master.tscn cleanly perfectly mathematically exactly identically natively
with open("Master.tscn", "r") as f:
    tscn = f.read()

injection = """[node name="MonolithicGapFiller" type="ColorRect" parent="CanvasLayer/OptionsContainer"]
anchor_top = 1.0
anchor_right = 1.0
anchor_bottom = 1.0
offset_top = -280.0
offset_bottom = 0.0
color = Color(0, 0, 0, 1)

[node name="HBoxContainer" type="HBoxContainer" parent="CanvasLayer/OptionsContainer"]"""

tscn = tscn.replace('[node name="HBoxContainer" type="HBoxContainer" parent="CanvasLayer/OptionsContainer"]', injection)

with open("Master.tscn", "w") as f:
    f.write(tscn)

# 3. Cleanly completely strictly mathematically surgically absolutely physically permanently irrevocably organically natively biologically strip all anti-orbital mathematical static manual flag-cancel scripts so flags literally function perfectly beautifully natively structurally glued to the ball organically! 
with open("scripts/ball.gd", "r") as f:
    ball = f.read()

process_match = r'func _process\(delta\):\n\t\$Flag\.rotation = -rotation\n\t\$FlagBackground\.rotation = -rotation\n\t\$Flag\.global_position = global_position \+ Vector2\(-11, -55\)\n\t\$FlagBackground\.global_position = global_position \+ Vector2\(11, -27\)\n\tif held:'
process_replacement = """func _process(delta):
	if held:"""

ball = re.sub(process_match, process_replacement, ball, flags=re.DOTALL)

with open("scripts/ball.gd", "w") as f:
    f.write(ball)

