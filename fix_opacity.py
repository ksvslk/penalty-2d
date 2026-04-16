import re

# Update multiplayer_ui.gd
with open("scripts/multiplayer_ui.gd", "r") as f:
    text = f.read()

# Make background completely solid to hide underlying UI cleanly
text = re.sub(
    r'bg\.color = Color\(0,\s*0,\s*0,\s*0\.9\)',
    'bg.color = Color(0.05, 0.05, 0.05, 1.0)',
    text
)

# And make the LineEdit a bit bigger to match the new massive scale!
text = re.sub(
    r'code_input\.custom_minimum_size = Vector2\(200, 60\)',
    'code_input.custom_minimum_size = Vector2(300, 120)\n\tcode_input.add_theme_font_size_override("font_size", 32)',
    text
)

# Make JOIN button share the rest of the space nicely (500 width)
text = re.sub(
    r'join_btn = _create_button\("JOIN"\)',
    'join_btn = _create_button("JOIN")\n\tjoin_btn.custom_minimum_size = Vector2(450, 120)',
    text
)

with open("scripts/multiplayer_ui.gd", "w") as f:
    f.write(text)

# Update options_container.gd
with open("scripts/options_container.gd", "r") as f:
    text2 = f.read()

# Make background completely solid to hide underlying UI cleanly
text2 = re.sub(
    r'bg\.color = Color\(0,\s*0,\s*0,\s*0\.9\)',
    'bg.color = Color(0.05, 0.05, 0.05, 1.0)',
    text2
)

with open("scripts/options_container.gd", "w") as f:
    f.write(text2)

