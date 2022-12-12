extends Button

export(Texture) var android_icon
export(Texture) var iphone_icon

func _ready():
	match OS.get_name():
		"Android":
			icon = android_icon
		"iOS":
			icon = iphone_icon
			set("custom_constants/hseparation", 40)
