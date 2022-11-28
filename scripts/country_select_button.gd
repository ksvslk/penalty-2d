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
