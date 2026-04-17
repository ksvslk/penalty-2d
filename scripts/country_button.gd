extends Button
class_name CountryButton

var country = "-"
var texture
var is_activated = false

func _ready():
	update_info()
	if not is_activated:
		$TextureButton.material.set_shader_parameter("is_disabled", true)
		
func activate_button():
	is_activated = true
	$TextureButton.material.set_shader_parameter("is_disabled", false)
	
func update_info():
	$TextureButton.texture = texture
	$Label.text = country
