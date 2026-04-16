with open("Master.tscn", "r") as f:
    text = f.read()

import re

# Move SelectedFlag back to top
text = re.sub(
    r'\[node name="SelectedFlag" type="TextureRect" parent="Level"\]\nanchor_left = 0\.5\nanchor_right = 0\.5\noffset_left = 496\.0\noffset_top = 1152\.0\noffset_bottom = 1262\.0',
    '[node name="SelectedFlag" type="TextureRect" parent="Level"]\nanchor_left = 0.5\nanchor_right = 0.5\noffset_left = 496.0\noffset_top = 16.0\noffset_bottom = 126.0',
    text
)

# Left align Label4 (BEST SCORE:)
text = re.sub(
    r'(\[node name="Label4" type="Label" parent="Level/Display/Highest"\][\s\S]*?text = "BEST SCORE:"\n)horizontal_alignment = 1',
    r'\1horizontal_alignment = 0',
    text
)

# Left align Label3 (TIME:)
text = re.sub(
    r'(\[node name="Label3" type="Label" parent="Level/Display/Time"\][\s\S]*?text = "TIME:"\n)horizontal_alignment = 1',
    r'\1horizontal_alignment = 0',
    text
)

# Left align Label2 (SCORE:)
text = re.sub(
    r'(\[node name="Label2" type="Label" parent="Level/Display/Score"\][\s\S]*?text = "SCORE:"\n)horizontal_alignment = 1',
    r'\1horizontal_alignment = 0',
    text
)

with open("Master.tscn", "w") as f:
    f.write(text)

