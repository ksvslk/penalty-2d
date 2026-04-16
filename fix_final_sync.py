import re

with open("scripts/options_container.gd", "r") as f:
    text = f.read()

# Completely disable the dynamic layout drift at the bottom. By removing this, we guarantee the UI permanently locks identically securely beneath the static physics grid of the soccer balls, natively ignoring Apple Notch UI holes.
text = text.replace('offset_bottom = -safe_bottom', 'offset_bottom = 0')

with open("scripts/options_container.gd", "w") as f:
    f.write(text)
