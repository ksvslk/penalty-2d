import re

with open("Master.tscn", "r") as f:
    text = f.read()

text = re.sub(
    r'\[node name="Display" type="HBoxContainer" parent="Level"\]\noffset_top = 1073\.0\noffset_bottom = 1200\.0',
    '[node name="Display" type="HBoxContainer" parent="Level"]\noffset_top = 1058.0\noffset_bottom = 1185.0',
    text
)

with open("Master.tscn", "w") as f:
    f.write(text)
