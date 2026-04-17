import re

with open("Master.tscn", "r") as f:
    text = f.read()

# Fix CountryScroller
target1_pattern = r'(\[node name="CountryScroller" type="ScrollContainer" parent="CanvasLayer/OptionsContainer/SelectCountry"\]\nanchor_right = 1\.0\nanchor_bottom = 1\.0\n)offset_top = 160\.0\noffset_bottom = -197\.0'
replacement1 = r'\1offset_top = 0.0\noffset_bottom = 0.0'
text = re.sub(target1_pattern, replacement1, text)

# Fix LevelScroller
target2_pattern = r'(\[node name="LevelScroller" type="ScrollContainer" parent="CanvasLayer/OptionsContainer"\]\nvisible = false\nanchor_right = 1\.0\nanchor_bottom = 1\.0\noffset_left = 1\.0\n)offset_top = 114\.0\noffset_bottom = -185\.0'
replacement2 = r'\1offset_left = 0.0\noffset_top = 0.0\noffset_bottom = 0.0'
text = re.sub(target2_pattern, replacement2, text)

with open("Master.tscn", "w") as f:
    f.write(text)

