extends Node2D


onready var pic = $pic
onready var texture_rect = $TextureRect

func _ready():
	var levels = Data.get_levels()
	for key in levels.keys():
			texture_rect.texture = load("res://art/flag/" + key + ".png")
			get_viewport().set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
			# Wait until the frame has finished before getting the texture.
			yield(VisualServer, "frame_post_draw")

			# Retrieve the captured image.
			var img = get_viewport().get_texture().get_data()

			# Flip it on the y-axis (because it's flipped).
			img.flip_y()

			img.save_png("user://" + levels.get(key)[0] +".png")

