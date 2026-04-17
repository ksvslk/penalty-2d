extends Button
class_name CountrySelectButton 

var flag = ""
var country = "-"
var texture

func _ready():
	update_info()


func update_info():
	icon = texture
	text = country
	
	# Dynamically shrink font size if text is too wide
	var font = get_theme_font("font")
	var f_size = 50
	add_theme_font_size_override("font_size", f_size)
	# Available width is around 820 (1080 - 100 margin - 160 icon)
	if font != null:
		while font.get_string_size(country, HORIZONTAL_ALIGNMENT_LEFT, -1, f_size).x > 820 and f_size > 15:
			f_size -= 2
			add_theme_font_size_override("font_size", f_size)
