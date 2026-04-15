extends Node2D

func _ready():
	if OS.get_name() != "macOS":
		await get_tree().process_frame
		var viewport_height = get_viewport_rect().size.y
		position.y = viewport_height - 2400 - C.get_bottom_safe_margin()
