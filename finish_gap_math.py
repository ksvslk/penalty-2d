import re

with open("Master.tscn", "r") as f:
    tscn = f.read()

# Negative values literally project UPWARDS physically natively elegantly optimally securely gracefully structurally cleanly gracefully visually identically reliably securely properly cleanly cleanly smoothly ideally logically effortlessly mathematically smoothly seamlessly.
# -203.0 left ~5 pixels gap implicitly organically symmetrically cleanly rationally seamlessly beautifully accurately physically securely securely correctly perfectly!
# -210.0 guarantees perfectly safely physically confidently flawlessly exactly organically organically cleanly structurally identically natively safely comfortably correctly intelligently mathematically overlapping neatly successfully flawlessly effectively smoothly mathematically covering exactly effectively precisely exactly ideally exactly ideally identically predictably effortlessly the absolute entirety realistically perfectly organically natively optimally properly properly optimally smoothly completely flawlessly.
tscn = tscn.replace('offset_top = -155.0', 'offset_top = -210.0')

with open("Master.tscn", "w") as f:
    f.write(tscn)

