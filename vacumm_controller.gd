extends Node2D

var small_zone_ref
var large_zone_ref

func _ready()->void:
	small_zone_ref = get_child(0)
	
	print(small_zone_ref)
	
	large_zone_ref = get_child(1)
	
	print(large_zone_ref)
	
	large_zone_ref.visible = false
	small_zone_ref.visible = false
	
func _process(delta: float)->void:
	if (Input.is_action_pressed("ui_small_zone")): # suck while button is held
		small_zone_ref.visible = true
	else:
		small_zone_ref.visible = false
		
	if (Input.is_action_pressed("ui_large_zone")):
		large_zone_ref.visible = true
	else:
		large_zone_ref.visible = false

	if (large_zone_ref.visible == true || small_zone_ref.visible == true):
		print("Sucking up an area!")
	else:
		print("No longer sucking a small area :(")
