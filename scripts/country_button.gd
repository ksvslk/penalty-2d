extends Button
class_name CountryButton

var country = "-"
var texture
var is_activated = false

func _ready():
	update_info()
	if not is_activated:
		self.disabled = true
		$TextureButton.material.set_shader_parameter("grayscale", true)
		
func activate_button():
	is_activated = true
	self.disabled = false
	$TextureButton.material.set_shader_parameter("grayscale", false)
	
func update_info():
	$TextureButton.texture = texture
	$Label.text = country
