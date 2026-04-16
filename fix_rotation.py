import re

with open("scripts/ball.gd", "r") as f:
    text = f.read()

# Fix Godot 3.x Control Node rotation!
# RigidBody2D rotation is in radians. rect_rotation is in degrees.
# 11.5539 is the original tilt angle of the Flag in degrees.
text = text.replace('$Flag.global_rotation = 0.201653', '$Flag.rect_rotation = 11.5539 - rad2deg(rotation)')

with open("scripts/ball.gd", "w") as f:
    f.write(text)

