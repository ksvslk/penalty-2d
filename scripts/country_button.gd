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
	
	# Dynamically shrink font size if text is too wide
	var font = $Label.get_theme_font("font")
	var f_size = 50
	$Label.add_theme_font_size_override("font_size", f_size)
	# Label width is around 740 (1000 - 260)
	if font != null:
		while font.get_string_size(country, HORIZONTAL_ALIGNMENT_LEFT, -1, f_size).x > 740 and f_size > 15:
			f_size -= 2
			$Label.add_theme_font_size_override("font_size", f_size)
