extends CharacterBody2D

const WALK_SPEED = 30
const RUN_AWAY = -75

var animator

var lights_ref
var light_level = 1 # get value from scene (1 is max, 0 is off)

var restart = false

var ghosts

signal stop_game # signal to tell other objects to stop moving

# Here we will control (or not really) control Alan

func _ready()->void:
	lights_ref = get_node("/root/Level/Lights")
	lights_ref.light_level.connect(_set_light_level)
	
	animator = get_child(0)
	
	ghosts = get_tree().get_nodes_in_group("Ghosts") # inital list of all ghost in the scene

func _process(delta: float) -> void:
	ghosts = get_tree().get_nodes_in_group("Ghosts") # updated list of all ghost in the scene

func _physics_process(delta: float) -> void:
	if (!restart):
		if (!is_on_floor()):
			# print("I'm floating here!")
			velocity.y += get_gravity().y * delta
			animator.stop()
		else:
			# print("I'm walking here!")
			velocity.x = WALK_SPEED * light_level
			if (light_level == 0):
				animator.play("cower")
			else:
				animator.play("walk_right")
	else:
		velocity.x = RUN_AWAY
		animator.flip_h = true
		animator.play("run_away")
		
	move_and_slide()
	
	# get_slide_collision()
	
	if ghosts.size() > 0: 
		for ghost in ghosts:
			if (ghost != null):
				if (ghost.overlaps_body(self)):
					print("Eek, a ghost!")
					restart = true
					stop_game.emit()
	
func _set_light_level(val : float)->void:
	light_level = 1 - val
	if (light_level <= .3):
		light_level = 0
