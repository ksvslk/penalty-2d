extends Button
class_name CountryButton 

var country = "-"
var texture
var is_activated = false
onready var label = $Label
onready var texture_button = $TextureButton


func _ready():
	texture_button.texture = texture
	label.text = country
	if is_activated:
		activate_button()
	else:
		deactivate_button()
	
	
func activate_button():
	disabled = false
	material.set("shader_param/grayscale", false)
	label.modulate.a = 1
	

func deactivate_button():
	disabled = true
	material.set("shader_param/grayscale", true)
	label.modulate.a = 0.15
	
