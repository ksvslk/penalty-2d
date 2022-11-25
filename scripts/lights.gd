extends Node2D

var lights := 0

signal lights_completely_on
signal lights_completely_off
var lights_off = true

	
func light_on():
	lights += 1
	if lights == get_child_count():
		lights_off = false
		emit_signal("lights_completely_on")


func light_off():
	lights -= 1
	if lights == 0:
		lights_off = true
		emit_signal("lights_completely_off")


func off():
	for c in get_children():
		c.disappear()
		
		
func on():
	for c in get_children():
		c.appear()
