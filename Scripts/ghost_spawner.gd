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
	camera_right_bounds = camera_ref.global_position.x + get_viewport().size.x * 0.5 / camera_ref.zoom.x
	camera_upper_bounds = camera_ref.global_position.y - get_viewport().size.y * 0.5 / camera_ref.zoom.y
	camera_lower_bounds = camera_ref.global_position.y + get_viewport().size.y * 0.5 / camera_ref.zoom.y
	
	camera_lower_bounds -= 16
	camera_upper_bounds += 16
	
	# print(camera_right_bounds, " ", camera_upper_bounds, " ", camera_lower_bounds)
	
	spawnTimer += delta
	
	if spawnTimer >= 32:
		spawnNumber += 1
	
	if spawnTimer >= SPAWN_TIME:
		spawnTimer = 0
		for i in range(spawnNumber):
			var newGhost = ghost.instantiate()
			newGhost.scale.x = rng.randf_range(MIN_SIZE, MAX_SIZE)
			
			var x_pos =  rng.randf_range(camera_right_bounds - 8, camera_right_bounds)
			var y_pos = rng.randf_range(camera_upper_bounds, camera_lower_bounds)
			print("Spawning at : ", x_pos, ", " , y_pos)
			
			newGhost.global_position.x = x_pos
			newGhost.global_position.y = y_pos
			newGhost.add_to_group("Ghosts")
			add_child(newGhost)
