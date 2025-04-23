extends Area2D

var vacuum_large_ref # large area slow suck
var vacuum_small_ref # small area fast suck
var camera_ref # reference to camera to keep ghosts within its bounds
var player_ref # reference to player scene

var animator

var isBigSucked = false
var isSmallSucked = false

const FAST_SHRINK = .01
const SLOW_SHRINK = .005
const X_SPEED = 40

var rng

var direction = -1 # starts facing the left

var stop_game = false

func _ready()->void:
	player_ref = get_node("/root/Level/Alan")
	
	player_ref.stop_game.connect(_stop_game)
	
	animator = get_child(1)
	
	vacuum_large_ref = get_node("/root/Level/Vacuum").get_child(2)
	vacuum_small_ref = get_node("/root/Level/Vacuum").get_child(1);
	
func _process(delta: float)->void:
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
		
		if self.scale.x <= .5:
			self.queue_free()
	else:
		animator.play("wave")
		
func _physics_process(delta: float) -> void:
	if (!stop_game):
		if (isBigSucked):
			global_position.x = move_toward(self.global_position.x, vacuum_large_ref.global_position.x, .25)
			global_position.y = move_toward(self.global_position.y, vacuum_large_ref.global_position.y, .25)
		elif (isSmallSucked):
			global_position.x = move_toward(self.global_position.x, vacuum_small_ref.global_position.x, .5)
			global_position.y = move_toward(self.global_position.y, vacuum_small_ref.global_position.y, .5)
		else:
			global_position.x += X_SPEED * delta * direction

func _stop_game()->void:
	stop_game = true
