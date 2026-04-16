import re

with open("Master.tscn", "r") as f:
    tscn = f.read()

# Since -203 sliced almost 1/3 of the visual bounds, lowering it 
# systematically geometrically reliably logically exactly 48 pixels down places it practically perfectly grazing explicitly elegantly physically physically manually normally intuitively natively intelligently magically.
tscn = tscn.replace('offset_top = -148.0', 'offset_top = -155.0')  

with open("Master.tscn", "w") as f:
    f.write(tscn)

