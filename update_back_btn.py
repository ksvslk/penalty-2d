import re

# 1. Update options_container.gd
with open("scripts/options_container.gd", "r") as f:
    text = f.read()

# The back button logic in options_container.gd
pattern = r'(?P<indent>\t+)(var local_back = Button\.new\(\)\n.*?)(?P<add_child>\t+inner_box\.add_child\(local_back\)\n)'
match = re.search(pattern, text, flags=re.DOTALL)
if match:
    original_block = match.group(0)
    setup_code = match.group(2)
    # Modify the attachment: instead of inner_box.add_child, we want to anchor it to m
    new_attachment = """\t\t\tlocal_back.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
\t\t\tlocal_back.offset_left = -450
\t\t\tlocal_back.offset_right = 450
\t\t\tlocal_back.offset_bottom = -150
\t\t\tlocal_back.offset_top = -290
\t\t\tm.add_child(local_back)
"""
    new_block = match.group(1) + setup_code + new_attachment
    text = text.replace(original_block, new_block)

with open("scripts/options_container.gd", "w") as f:
    f.write(text)

# 2. Update multiplayer_ui.gd
with open("scripts/multiplayer_ui.gd", "r") as f:
    m_text = f.read()

m_pattern = r'(\tback_btn = _create_button\("BACK"\)\n\tback_btn\.pressed\.connect\(_on_back_pressed\)\n)\tmain_container\.add_child\(back_btn\)'
m_replacement = r"""\1	back_btn.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	back_btn.offset_left = -450
	back_btn.offset_right = 450
	back_btn.offset_bottom = -150
	back_btn.offset_top = -290
	add_child(back_btn)"""

m_text = re.sub(m_pattern, m_replacement, m_text)

with open("scripts/multiplayer_ui.gd", "w") as f:
    f.write(m_text)

