extends CollisionShape2D

var initial_y = 0.0

func _ready():
	if has_meta("shifted"):
		return
	initial_y = position.y
	if OS.get_name() != "macOS":
		await get_tree().process_frame
		var viewport_height = get_viewport_rect().size.y
		position.y = initial_y + (viewport_height - 2400 - C.get_bottom_safe_margin())
		set_meta("shifted", true)
