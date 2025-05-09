extends RigidBody2D

var vacuum_large_ref # large area slow suck
var vacuum_small_ref # small area fast suck
var camera_ref # reference to camera to keep ghosts within its bounds
var player_ref # reference to player scene

var leftEdge

var animator

var isBigSucked = false
var isSmallSucked = false

var direction = -1 # starts facing the left

var stop_game = false

func _ready()->void:
	player_ref = get_node("/root/Level/Alan")
	player_ref.stop_game.connect(_stop_game)
	
	camera_ref = get_node("/root/Level/Alan/Camera2D")
	
	animator = get_child(0)
	
	vacuum_large_ref = get_node("/root/Level/Vacuum").get_child(2)
	vacuum_small_ref = get_node("/root/Level/Vacuum").get_child(1);
	
func _process(_delta: float)->void:
	leftEdge  = computeMinimumPointBoundary().x
	
	if(!stop_game):
		if (vacuum_large_ref.overlaps_body(self)):
			isBigSucked = true
			isSmallSucked = false
		elif (vacuum_small_ref.overlaps_body(self)):
			isSmallSucked = true
			isBigSucked = false
		else:
			isBigSucked = false
			isSmallSucked = false
	
		if (isBigSucked || isSmallSucked):
			animator.play("move")
		else:
			animator.play("float down")
			
		if self.global_position.x < leftEdge:
			self.queue_free() # delete ghost if it goes off camera
	else:
		animator.play("wave")
		
func _physics_process(delta: float) -> void:
	if (!stop_game):
		if (isBigSucked):
			self.gravity_scale = 0
			global_position.x = move_toward(self.global_position.x, vacuum_large_ref.global_position.x, .25)
			global_position.y = move_toward(self.global_position.y, vacuum_large_ref.global_position.y, .25)
		elif (isSmallSucked):
			self.gravity_scale = 0
			global_position.x = move_toward(self.global_position.x, vacuum_small_ref.global_position.x, .5)
			global_position.y = move_toward(self.global_position.y, vacuum_small_ref.global_position.y, .5)
		else:
			self.linear_velocity.y = 1.5

func _stop_game()->void:
	stop_game = true
		
func computeMinimumPointBoundary():
	# Get view rectangle
	var ctrans = get_canvas_transform()
	var min_pos = (-ctrans.get_origin() / ctrans.get_scale())
	return min_pos
