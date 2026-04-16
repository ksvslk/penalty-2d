import re

with open("scripts/options_container.gd", "r") as f:
    text = f.read()

text = text.replace('if has_node("../MonolithicGapFiller"):', 'if has_node("MonolithicGapFiller"):')
text = text.replace('var gap = get_node("../MonolithicGapFiller")', 'var gap = get_node("MonolithicGapFiller")')
text = text.replace('gap.global_position.y = screen_y', 'gap.position.y = screen_y\n\t\tgap.offset_top = screen_y - gap.get_parent().global_position.y')

with open("scripts/options_container.gd", "w") as f:
    f.write(text)

