import re

button_tscn_content = """[gd_scene load_steps=5 format=3 uid="uid://c2s2gj8gq3u1b"]

[ext_resource type="Script" path="res://scripts/country_button.gd" id="2_script"]
[ext_resource type="Material" path="res://shader/Grayscale.tres" id="3_material"]
[ext_resource type="FontFile" path="res://fonts/Alexandria-Bold.ttf" id="4_font"]

[sub_resource type="StyleBoxFlat" id="StyleBoxFlat_0y68e"]
content_margin_left = 50.0
content_margin_right = 50.0
content_margin_top = 20.0
content_margin_bottom = 20.0
bg_color = Color(0, 0, 0, 1)

[node name="CountryButton" type="Button"]
custom_minimum_size = Vector2(1080, 264)
offset_right = 1080.0
offset_bottom = 264.0
size_flags_horizontal = 3
theme_override_styles/hover = SubResource("StyleBoxFlat_0y68e")
theme_override_styles/pressed = SubResource("StyleBoxFlat_0y68e")
theme_override_styles/normal = SubResource("StyleBoxFlat_0y68e")
theme_override_styles/disabled = SubResource("StyleBoxFlat_0y68e")
script = ExtResource("2_script")

[node name="HBoxContainer" type="HBoxContainer" parent="."]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
mouse_filter = 2
theme_override_constants/separation = 20
alignment = 2

[node name="TextureButton" type="TextureRect" parent="HBoxContainer"]
material = ExtResource("3_material")
custom_minimum_size = Vector2(202, 163)
layout_mode = 2
mouse_filter = 2
expand_mode = 1
stretch_mode = 5

[node name="Label" type="Label" parent="HBoxContainer"]
layout_mode = 2
size_flags_vertical = 1
theme_override_fonts/font = ExtResource("4_font")
theme_override_font_sizes/font_size = 50
text = "1. Andorra"
vertical_alignment = 1
"""

with open("scenes/CountryButton.tscn", "w") as f:
    f.write(button_tscn_content)

country_btn_gd = """extends Button
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
"""

with open("scripts/country_button.gd", "w") as f:
    f.write(country_btn_gd)

