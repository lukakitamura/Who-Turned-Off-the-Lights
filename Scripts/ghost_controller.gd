extends Area2D

var vacuum_large_ref # large area slow suck
var vacuum_small_ref # small area fast suck
var animator

var isBigSucked = false
var isSmallSucked = false

const FAST_SHRINK = .01
const SLOW_SHRINK = .005
const X_SPEED = 40

var rng

var direction = -1 # starts facing the left

func _ready()->void:
	animator = get_child(1)
	
	vacuum_large_ref = get_node("/root/Level/Vacuum").get_child(2)
	vacuum_small_ref = get_node("/root/Level/Vacuum").get_child(1);
	
func _process(delta: float) -> void:
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
	elif (isSmallSucked):
		self.scale -= Vector2(FAST_SHRINK, FAST_SHRINK)
		
	if self.scale.x <= .5:
		self.queue_free()
		
	if direction == 1:
		animator.play("drift_right")
	elif direction == -1:
		animator.play("drift_left")
		
func _physics_process(delta: float) -> void:
	if (isBigSucked):
		pass
	elif (isSmallSucked):
		pass
	else:
		global_position.x += X_SPEED * delta * direction
