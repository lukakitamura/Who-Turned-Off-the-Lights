extends Node2D

var small_zone_ref
var large_zone_ref
var player_ref

var vacuum_sprite

var large_zone_animator
var small_zone_animator

var vacuum_power = 100 # vacuum power, won't work if at 0
const MIN_VACUUM_POWER = 20 # if vacuum dies, won't restart until it has 20 power

var can_suck = false
var has_released = true # holding button down forever
var stop_game = false

func _ready()->void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)
	
	player_ref = get_node("/root/Level/Alan")
	
	player_ref.stop_game.connect(_stop_game)
	
	vacuum_sprite = get_child(0)
	
	small_zone_ref = get_child(1) # small area is 2nd child of vacuum
	small_zone_animator = small_zone_ref.get_child(0)
	
	print(small_zone_ref.name)
	
	large_zone_ref = get_child(2) # large area is 3rd child of vacuum
	large_zone_animator = large_zone_ref.get_child(0)
	
	print(large_zone_ref.name)
	
	# set area2Ds to be invisible and not detectable
	large_zone_ref.visible = false
	large_zone_ref.monitorable = false
	small_zone_ref.visible = false
	small_zone_ref.monitorable = false 
	
func _process(delta: float)->void:
	if (!stop_game):
		# print(vacuum_power)
	
		self.global_position = get_global_mouse_position()
	
		if (Input.is_action_just_released("ui_small_zone") || Input.is_action_just_released("ui_large_zone")):
			has_released = true
		
		if (can_suck):
			if (Input.is_action_pressed("ui_small_zone")): # suck while button is held
				small_zone_ref.visible = true
				small_zone_ref.monitoring = true
				small_zone_animator.play("suck_up")
				vacuum_power -= 20 * delta
				has_released = false
			elif (Input.is_action_pressed("ui_large_zone")):
				large_zone_ref.visible = true
				large_zone_ref.monitoring = true
				large_zone_animator.play("suck_up")
				vacuum_power -= 30 * delta
				has_released = false
			else:
				small_zone_ref.visible = false
				small_zone_ref.monitoring = false
				small_zone_animator.stop()
				large_zone_ref.visible = false
				large_zone_ref.monitoring = false
				large_zone_animator.stop()
		else:
			small_zone_ref.visible = false
			small_zone_ref.monitoring = false
			small_zone_animator.stop()
			large_zone_ref.visible = false
			large_zone_ref.monitoring = false
			large_zone_animator.stop()
	
		if (vacuum_power < 100 && has_released):
				vacuum_power += 20 * delta
	
		if (vacuum_power <= 0):
			can_suck = false

		if vacuum_power >= MIN_VACUUM_POWER:
			can_suck = true
	
		if (large_zone_ref.visible == true || small_zone_ref.visible == true):
			vacuum_sprite.visible = false
			# print("Sucking up an area!")
		else:
			vacuum_sprite.visible = true
			# print("No longer sucking a small area :(")
	else:
		vacuum_sprite.visible = true
		small_zone_ref.visible = false
		small_zone_ref.monitoring = false
		small_zone_animator.stop()
		large_zone_ref.visible = false
		large_zone_ref.monitoring = false
		large_zone_animator.stop()

func _stop_game()->void:
	stop_game = true
