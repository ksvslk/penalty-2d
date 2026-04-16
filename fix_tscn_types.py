import re

with open("Master.tscn", "r") as f:
    text = f.read()

# Change PlayGamesList type
text = re.sub(
    r'\[node name="PlayGamesList" type="VBoxContainer" parent="CanvasLayer/OptionsContainer"\]',
    '[node name="PlayGamesList" type="Control" parent="CanvasLayer/OptionsContainer"]',
    text
)

# Change BonusList type
text = re.sub(
    r'\[node name="BonusList" type="VBoxContainer" parent="CanvasLayer/OptionsContainer"\]',
    '[node name="BonusList" type="Control" parent="CanvasLayer/OptionsContainer"]',
    text
)

# Change OptionsList type
text = re.sub(
    r'\[node name="OptionsList" type="VBoxContainer" parent="CanvasLayer/OptionsContainer"\]',
    '[node name="OptionsList" type="Control" parent="CanvasLayer/OptionsContainer"]',
    text
)

with open("Master.tscn", "w") as f:
    f.write(text)

