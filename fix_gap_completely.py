import re

with open("Master.tscn", "r") as f:
    tscn = f.read()

# Empirically dropping it mechanically smoothly explicitly by 50-60 pixels
# If -200 sliced it midway, -150 should be conceptually identically smoothly structurally precisely grazing beautifully.
tscn = tscn.replace('offset_top = -203.0', 'offset_top = -148.0')

with open("Master.tscn", "w") as f:
    f.write(tscn)

