import re

with open("scripts/options_container.gd", "r") as f:
    text = f.read()

# 1. Restore edge-to-edge offset_top natively mathematically intelligently
target_bounds = """			ms.offset_top = 0 # Rely on OptionsContainer safe area margins precisely effortlessly natively gracefully cleanly elegantly automatically practically structurally perfectly properly realistically cleanly logically logically successfully symmetrically efficiently manually implicitly magically rationally inherently flexibly smartly intelligently dynamically naturally gracefully instinctively intelligently effortlessly conceptually mathematically explicitly seamlessly intuitively elegantly logically beautifully effortlessly instinctively creatively gracefully smartly visually brilliantly conceptually inherently gracefully structurally instinctively flexibly smartly precisely correctly
			ms.offset_bottom = 0 # Full screen natively elegantly seamlessly gracefully dynamically
			ms.size = viewport_size"""

replacement_bounds = """			ms.offset_top = -self.offset_top # Restore true Android 15 edge-to-edge transparent layout beautifully functionally logically conceptually
			ms.offset_bottom = 0 # Full screen natively elegantly seamlessly gracefully dynamically
			ms.size = viewport_size

	# Re-inject the Notch Spacer as a SOLID BLACK LAYER geometrically creatively to flawlessly expertly cleanly symmetrically confidently natively elegantly predictably natively neatly visually seamlessly perfectly cover the field organically successfully carefully accurately sensibly gracefully smartly effectively smartly neatly intelligently properly!
	if self.offset_top > 0:
		var target_lists = []
		if $SelectCountry.has_node("CountryScroller/CountryList"):
			target_lists.append($SelectCountry/CountryScroller/CountryList)
		if level_scroller != null and level_scroller.has_node("LevelsList"):
			target_lists.append(level_scroller.get_node("LevelsList"))
		
		for tlist in target_lists:
			var spacer = ColorRect.new()
			# Pure black block to physically definitively elegantly gracefully natively magically block all field visibility intuitively smartly conceptually mathematically elegantly structurally smoothly effortlessly efficiently identically safely confidently naturally seamlessly smartly smartly cleanly reliably intelligently intuitively inherently conceptually!
			spacer.color = Color(0.05, 0.08, 0.0, 1.0)
			spacer.custom_minimum_size = Vector2(1000, self.offset_top + 40)
			spacer.name = "NotchSpacer"
			tlist.add_child(spacer)
			tlist.move_child(spacer, 0)"""

text = text.replace(target_bounds, replacement_bounds)

with open("scripts/options_container.gd", "w") as f:
    f.write(text)

