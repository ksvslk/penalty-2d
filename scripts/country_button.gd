extends Button
class_name CountryButton 

var country = "-"
var texture
onready var label = $Label
onready var texture_button = $TextureButton

func _ready():
	texture_button.texture_normal = texture
	label.text = country
