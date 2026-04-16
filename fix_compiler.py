import re

with open("scripts/ball.gd", "r") as f:
    text = f.read()

# Fix Godot 4.x function names and syntax!
text = text.replace('$Flag.rect_rotation = 11.5539 - rad2deg(rotation)', '$Flag.rotation = 0.201653 - rotation')

with open("scripts/ball.gd", "w") as f:
    f.write(text)

