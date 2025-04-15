extends Area2D

var vacuum_large_ref
var vacuum_small_ref

var isBigSucked = false
var isSmallSucked = false

const FAST_SHRINK = .5
const SLOW_SHRINK = .25
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
	
	if (isBigSucked || isSmallSucked):
		print("Help, I am being sucked!")
		pass
