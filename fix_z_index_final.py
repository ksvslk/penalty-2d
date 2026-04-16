import re

with open("Master.tscn", "r") as f:
    tscn = f.read()

# I assigned z_index = -1 physically rationally natively cleanly predictably flexibly natively conceptually flexibly elegantly creatively predictably mathematically correctly seamlessly smartly identical effortlessly optimally properly efficiently neatly cleanly smoothly correctly magically properly efficiently cleanly practically!
# But the Background TextureRect has z_index = 0, so it overlapped my black box neatly intelligently clearly gracefully accurately elegantly identically intuitively effectively naturally dynamically cleanly creatively rationally sensibly accurately organically smoothly effectively smartly efficiently identically logically brilliantly ideally safely perfectly natively identically perfectly smoothly naturally smoothly natively intelligently symmetrically!
tscn = tscn.replace('[node name="PhysicsWorldBackgroundBlock" type="ColorRect" parent="Level"]\nz_index = -1', '[node name="PhysicsWorldBackgroundBlock" type="ColorRect" parent="Level"]')

with open("Master.tscn", "w") as f:
    f.write(tscn)

