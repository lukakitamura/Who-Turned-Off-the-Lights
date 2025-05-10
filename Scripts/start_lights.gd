extends Node2D

var reset_timer = false
var countdown = 0

const TIME = 2

signal light_level

func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_start"):
		self.self_modulate.a = 0
		light_level.emit()
		
	if (get_tree().current_scene.name != "Start Screen" && Input.is_action_pressed("ui_quit")):
		self.self_modulate.a = 1
		reset_timer = true
		
	if reset_timer == true:
		countdown += delta
	
	if countdown >= TIME:
		get_tree().change_scene_to_file("res://Scenes/Start Screen.tscn")
