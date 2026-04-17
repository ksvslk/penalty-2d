import re

with open("Master.tscn", "r") as f:
    text = f.read()

# Fix LevelScroller duplicate offset_left
target_pattern = r'offset_left = 1\.0\n+offset_left = 0\.0'
replacement = r'offset_left = 0.0'
text = re.sub(target_pattern, replacement, text)

with open("Master.tscn", "w") as f:
    f.write(text)

