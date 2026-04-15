extends Button
class_name CountryButton

var country := "-"
var texture: Texture2D
var is_activated := false
@onready var label: Label = $Label
@onready var texture_rect: TextureRect = $TextureButton # Assuming this is a TextureRect node

func _ready() -> void:
	texture_rect.texture = texture
	label.text = country
	if is_activated:
		activate_button()
	else:
		deactivate_button()
	
	
func activate_button() -> void:
	disabled = false
	# In Godot 4, use the specific 'set_shader_parameter' method.
	if material:
		material.set_shader_parameter("grayscale", false)
	label.modulate.a = 1.0
	

func deactivate_button() -> void:
	disabled = true
	# In Godot 4, use the specific 'set_shader_parameter' method.
	if material:
		material.set_shader_parameter("grayscale", true)
	label.modulate.a = 0.15
