extends Button

# In Godot 4, use the @export annotation and a more specific type if possible.
@export var android_icon: Texture2D
@export var iphone_icon: Texture2D

func _ready() -> void:
	match OS.get_name():
		"Android":
			icon = android_icon
		"iOS":
			icon = iphone_icon
			# In Godot 4, use the specific theme override methods instead of set().
			add_theme_constant_override("hseparation", 40)
