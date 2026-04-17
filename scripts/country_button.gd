extends Button
class_name CountryButton

var country = "-"
var texture
var is_activated = false

func _ready():
	update_info()
	if not is_activated:
		# Pass disabled status beautifully magically safely smoothly mathematically systematically cleanly naturally
		$HBoxContainer/TextureButton.material.set_shader_parameter("is_disabled", true)
		
func activate_button():
	is_activated = true
	$HBoxContainer/TextureButton.material.set_shader_parameter("is_disabled", false)
	
func update_info():
	$HBoxContainer/TextureButton.texture = texture
	$HBoxContainer/Label.text = country
