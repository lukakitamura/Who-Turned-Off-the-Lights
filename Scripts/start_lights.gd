extends Node2D

signal light_level

func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_start"):
		self.self_modulate = 0
		light_level.emit()
