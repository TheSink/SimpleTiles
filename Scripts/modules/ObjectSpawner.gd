extends Node


func SpawnLight(position,enabled=true,color=Color(1,1,1),energy=1,shadows=false,scale=1,mode=Light2D.MODE_ADD):
	var light = Light2D.new()
	add_child(light)
	light.set_texture(load("res://torchlight.png"))
	light.global_position = position
	light.set_color(color)
	light.set_energy(energy)
	light.set_texture_scale(scale)
	light.set_shadow_enabled(shadows)
	light.mode = mode
	light.set_enabled(enabled)
	return light
