extends Node2D

var player_ref

var stop_game = false

const DECAY_RATE = 10
const INCREASE_RATE = 10

signal light_level

var START_SCREEN
var timer = 1
var reset = false

var inputVector = Vector2.ONE 

func _ready()->void:
	player_ref = get_node("/root/Level/Alan")
	player_ref.stop_game.connect(_stop_game)
	
func _process(delta: float) -> void:
	
	if (!reset):
		if (!stop_game):
			'''
			if (Input.is_action_pressed("ui_lights")):
				self_modulate.a -= INCREASE_RATE / 33.0 * delta
				self_modulate.a = clamp(self_modulate.a, 0, 1)
				# print("Making Screen Brighter")
			else:
				self_modulate.a += DECAY_RATE / 75.0 * delta
				self_modulate.a = clamp(self_modulate.a, 0, 1)
				# print("Screen is getting darker")
			'''
			self_modulate.a = get_input_vector().x
		else:
			self_modulate.a = 0 # turn on lights when game ends
		
		light_level.emit(self_modulate.a)
		
		if Input.is_action_pressed("ui_quit"):
			reset = true
		#print(get_input_vector().x)
		#print(Input.get_connected_joypads())
		# print(self_modulate.a)
	else:
		self_modulate.a = 1 #turn lights off if player gives up
		timer -= delta
	print(reset)
	if timer <= 0:
		get_tree().change_scene_to_file("res://Scenes/Start Screen.tscn")

func _stop_game()->void:
	stop_game = true

func get_input_vector():
	inputVector.x = remap(Input.get_action_strength("light_up") - Input.get_action_strength("light_down"), -1, 1, 1, 0)
	return inputVector 
