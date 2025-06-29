extends Area2D

var vacuum_large_ref # large area slow suck
var vacuum_small_ref # small area fast suck
var camera_ref # reference to camera to keep ghosts within its bounds
var player_ref # reference to player scene
var light_ref

var leftEdge

var animator

var isBigSucked = false
var isSmallSucked = false
var targetPlayer = false # whether to go after player or not

const FAST_SHRINK = .03
const SLOW_SHRINK = .01
const X_SPEED = 20

var rng

var direction = -1 # starts facing the left

var stop_game = false

func _ready()->void:
	player_ref = get_node("/root/Level/Alan")
	player_ref.stop_game.connect(_stop_game)
	
	light_ref = get_node("/root/Level/Lights")
	if light_ref != null:
		light_ref.light_level.connect(_target_player)
	
	camera_ref = get_node("/root/Level/Alan/Camera2D")
	
	animator = get_child(1)
	
	vacuum_large_ref = get_node("/root/Level/Vacuum").get_child(2)
	vacuum_small_ref = get_node("/root/Level/Vacuum").get_child(1);
	
func _process(_delta: float)->void:
	leftEdge  = computeMinimumPointBoundary().x
	
	if(!stop_game):
		if (vacuum_large_ref.overlaps_area(self)):
			isBigSucked = true
			isSmallSucked = false
		elif (vacuum_small_ref.overlaps_area(self)):
			isSmallSucked = true
			isBigSucked = false
		else:
			isBigSucked = false
			isSmallSucked = false
	
		if (isBigSucked):
			self.scale -= Vector2(SLOW_SHRINK, SLOW_SHRINK)
			animator.play("panic")
		elif (isSmallSucked):
			self.scale -= Vector2(FAST_SHRINK, FAST_SHRINK)
			animator.play("panic")
		else:
			if direction == 1:
				animator.play("drift_right")
			elif direction == -1:
				animator.play("drift_left")
		
		if self.scale.x <= .5 || self.scale.y <= .5:
			self.queue_free()
			
		if self.global_position.x < leftEdge:
			self.queue_free() # delete ghost if it goes off camera
	else:
		animator.play("wave")
		
func _physics_process(delta: float) -> void:
	if (!stop_game):
		if (isBigSucked):
			global_position.x = move_toward(self.global_position.x, vacuum_large_ref.global_position.x, .15)
			global_position.y = move_toward(self.global_position.y, vacuum_large_ref.global_position.y, .15)
		elif (isSmallSucked):
			global_position.x = move_toward(self.global_position.x, vacuum_small_ref.global_position.x, .25)
			global_position.y = move_toward(self.global_position.y, vacuum_small_ref.global_position.y, .25)
		else:
			if (targetPlayer):
				global_position.x = move_toward(self.global_position.x, player_ref.global_position.x, delta * X_SPEED * 1.25)
				global_position.y = move_toward(self.global_position.y, player_ref.global_position.y, delta * X_SPEED * .75)
			else:
				global_position.x += X_SPEED * delta * direction

func _stop_game()->void:
	stop_game = true

# change ghost behavior if lights get too dark
func _target_player(light_level: float)->void:
	if light_level <= .3: # closer to 0 is more light
		targetPlayer = false
	else:
		targetPlayer = true
		
func computeMinimumPointBoundary():
	# Get view rectangle
	var ctrans = get_canvas_transform()
	var min_pos = (-ctrans.get_origin() / ctrans.get_scale())
	return min_pos
