import re

with open("Master.tscn", "r") as f:
    text = f.read()

# Replace offset_top = 1136.0 and offset_bottom = 1263.0 with the perfectly snapped bounds
text = re.sub(
    r'\[node name="Display" type="HBoxContainer" parent="Level"\]\noffset_top = 1136\.0\noffset_bottom = 1263\.0',
    '[node name="Display" type="HBoxContainer" parent="Level"]\noffset_top = 1073.0\noffset_bottom = 1200.0',
    text
)

with open("Master.tscn", "w") as f:
    f.write(text)
