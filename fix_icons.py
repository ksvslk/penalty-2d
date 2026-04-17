import re

with open("scripts/options_container.gd", "r") as f:
    text = f.read()

pattern = r'(?P<indent>\t+)(node\.add_theme_stylebox_override\("pressed", primary_style\))'

replacement = r"""\1\2
\1node.add_theme_constant_override("h_separation", 40)
\1node.add_theme_constant_override("icon_max_width", 65)"""

new_text = re.sub(pattern, replacement, text)

with open("scripts/options_container.gd", "w") as f:
    f.write(new_text)

