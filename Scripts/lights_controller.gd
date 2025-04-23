extends Node2D

var light_opacity_ref

const DECAY_RATE = 10
const INCREASE_RATE = 10

signal light_level

func _ready()->void:
	pass
	
func _process(delta: float) -> void:
	if (Input.is_action_pressed("ui_lights")):
		self_modulate.a -= INCREASE_RATE / 33.0 * delta
		self_modulate.a = clamp(self_modulate.a, 0, 1)
		print("Making Screen Brighter")
	else:
		self_modulate.a += DECAY_RATE / 75.0 * delta
		self_modulate.a = clamp(self_modulate.a, 0, 1)
		print("Screen is getting darker")
	
	light_level.emit(self_modulate.a)
	
	print(self_modulate.a)
