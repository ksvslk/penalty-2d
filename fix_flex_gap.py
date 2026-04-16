import re

with open("scripts/options_container.gd", "r") as f:
    text = f.read()

# Add dynamic anchored fill block exactly behind HBoxContainer stretching up strictly 300 pixels forming impenetrable structural shelf!
injection = """
	var gap_filler = ColorRect.new()
	gap_filler.color = Color(0, 0, 0, 1.0)
	gap_filler.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	gap_filler.offset_bottom = -163.0  # Align strictly with top edge of HBoxContainer layout mathematically
	gap_filler.offset_top = -300.0     # Stretch violently upward fully structurally burying into the strict ball overlap depth mathematically
	add_child(gap_filler)
	move_child(gap_filler, $HBoxContainer.get_index())
"""

# inject seamlessly inside _ready natively
ready_match = r'func _ready\(\):'
text = re.sub(ready_match, f'func _ready():\n{injection}', text)

with open("scripts/options_container.gd", "w") as f:
    f.write(text)

