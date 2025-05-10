extends Node2D

# spawn ghosts within the camera bounds

const MIN_SIZE = 1     # size variation for the ghosts
const MAX_SIZE = 1.75
const SPAWN_TIME = 4 # spawn new ghost(s) every 4 seconds

var spawnTimer = 0

var spawnNumber = 1 # number of ghosts to spawn at a time

# necessary boundaries to spawn ghost within the camera frame
var camera_ref
var camera_right_bounds
var camera_lower_bounds
var camera_upper_bounds

var rng = RandomNumberGenerator.new()

var ghost

func _ready() -> void:
	rng.randomize()
	
	ghost = preload("res://Scenes/Small Ghost.tscn") # load ghost scene to be spawned
	
	camera_ref = get_node("/root/Level/Alan/Camera2D")

func _process(delta: float) -> void:	
	camera_upper_bounds = computeMinimumPointBoundary().y
	camera_lower_bounds = computeMaximumPointBoundary().y
	camera_right_bounds = computeMaximumPointBoundary().x
	
	# print(camera_upper_bounds)
	
	spawnTimer += delta
	
	if spawnTimer >= 24:
		spawnNumber += 1
	
	if spawnTimer >= SPAWN_TIME:
		spawnTimer = 0
		for i in range(spawnNumber):
			pass
			var newGhost = ghost.instantiate()
			newGhost.scale.x = rng.randf_range(MIN_SIZE, MAX_SIZE)
			
			var x_pos =  rng.randf_range(camera_right_bounds - 8, camera_right_bounds)
			var y_pos = rng.randf_range(camera_upper_bounds + 64, camera_lower_bounds - 32)
			print("Spawning at : ", x_pos, ", " , y_pos)
			
			newGhost.global_position.x = x_pos
			newGhost.global_position.y = y_pos
			newGhost.add_to_group("Ghosts")
			add_child(newGhost)

# Functions to compute max and min boundaries of camera 
# Borrowed from some dude on the internet

func computeMinimumPointBoundary():
	# Get view rectangle
	var ctrans = get_canvas_transform()
	var min_pos = (-ctrans.get_origin() / ctrans.get_scale())
	return min_pos

func computeMaximumPointBoundary():
	# Get view rectangle
	var ctrans = get_canvas_transform()
	var min_pos = -ctrans.get_origin() / ctrans.get_scale()
	var view_size = get_viewport_rect().size / ctrans.get_scale()
	var max_pos = min_pos + view_size
	return max_pos
