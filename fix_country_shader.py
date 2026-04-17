import re

with open("scenes/CountryButton.tscn", "r") as f:
    text = f.read()

# 1. Remove material from Button
text = re.sub(r'material = ExtResource\( 3 \)\n', '', text)

# 2. Add material to TextureRect instead of use_parent_material
text = re.sub(r'use_parent_material = true\n', 'material = ExtResource( 3 )\n', text)

with open("scenes/CountryButton.tscn", "w") as f:
    f.write(text)

