extends Area2D

var vacuum_large_ref # large area slow suck
var vacuum_small_ref # small area fast suck

var isBigSucked = false
var isSmallSucked = false

const FAST_SHRINK = .01
const SLOW_SHRINK = .005
const SPEED = 50

func _ready()->void:
	vacuum_large_ref = get_node("/root/Level/Vacuum").get_child(2)
	vacuum_small_ref = get_node("/root/Level/Vacuum").get_child(1);

	print(vacuum_large_ref.name + " " + vacuum_small_ref.name)
	
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
