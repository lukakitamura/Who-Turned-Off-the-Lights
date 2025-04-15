extends Node2D

var small_zone_ref
var large_zone_ref
var vacuum_sprite

func _ready()->void:
	vacuum_sprite = get_child(0)
	
	small_zone_ref = get_child(1) # small area is 2nd child of vacuum
	
	print(small_zone_ref.name)
	
	large_zone_ref = get_child(2) # large area is 3rd child of vacuum
	
	print(large_zone_ref.name)
	
	# set area2Ds to be invisible and not detectable
	large_zone_ref.visible = false
	large_zone_ref.monitorable = false
	small_zone_ref.visible = false
	small_zone_ref.monitorable = false 
	
func _process(delta: float)->void:
	self.global_position = get_global_mouse_position()
	
	if (Input.is_action_pressed("ui_small_zone")): # suck while button is held
		small_zone_ref.visible = true
		small_zone_ref.monitoring = true
	else:
		small_zone_ref.visible = false
		small_zone_ref.monitoring = false
		
	if (Input.is_action_pressed("ui_large_zone")):
		large_zone_ref.visible = true
		large_zone_ref.monitoring = true
	else:
		large_zone_ref.visible = false
		large_zone_ref.monitoring = false

	if (large_zone_ref.visible == true || small_zone_ref.visible == true):
		vacuum_sprite.visible = false
		# print("Sucking up an area!")
	else:
		vacuum_sprite.visible = true
		# print("No longer sucking a small area :(")
