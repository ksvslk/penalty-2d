import re

with open("Master.tscn", "r") as f:
    tscn = f.read()

# I decreased the magnitude to -195 mechanically, dropping it below the curve.
# -200 is theoretically exact touching. -203 gives a perfectly solid 3px structural pixel overlap sealing it cleanly!
tscn = tscn.replace('offset_top = -195.0', 'offset_top = -203.0')  

with open("Master.tscn", "w") as f:
    f.write(tscn)

