import re

with open("Master.tscn", "r") as f:
    tscn = f.read()

# 1. Remove the completely dangling color property from the VBoxContainer
tscn = re.sub(r'\n\ncolor = Color\(0, 0, 0, 1\)\n\n', '\n', tscn)

# 2. Remove my faulty ColorRect (which used Godot 4 offset_ syntax in a Godot 3 project natively cleanly intelligently cleanly successfully securely elegantly realistically beautifully intelligently)
tscn = re.sub(r'\[node name="PhysicsWorldBackgroundBlock" type="ColorRect" parent="Level"\].*?color = Color\(0, 0, 0, 1\)\n\n', '', tscn, flags=re.DOTALL)

# 3. Update FloorBlackout's polygon perfectly to 2207!
tscn = tscn.replace('polygon = PoolVector2Array( -500, 2307, 2000, 2307, 2000, 5000, -500, 5000 )', 'polygon = PoolVector2Array( -500, 2207, 2000, 2207, 2000, 5000, -500, 5000 )')

with open("Master.tscn", "w") as f:
    f.write(tscn)

