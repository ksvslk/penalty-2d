import re

with open("scenes/CountryButton.tscn", "r") as f:
    text = f.read()

pattern = r"""theme_override_styles/hover = SubResource\( 37 \)
theme_override_styles/pressed = SubResource\( 37 \)
theme_override_styles/normal = SubResource\( 37 \)"""

replacement = """theme_override_styles/hover = SubResource( 37 )
theme_override_styles/pressed = SubResource( 37 )
theme_override_styles/normal = SubResource( 37 )
theme_override_styles/disabled = SubResource( 37 )"""

text = text.replace(pattern, replacement)

with open("scenes/CountryButton.tscn", "w") as f:
    f.write(text)

