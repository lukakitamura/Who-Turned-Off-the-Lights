extends CharacterBody2D

const MOVE_SPEED = 50

var light_ref
var start_game = false

var animator

func _ready() -> void:
	animator = self.get_child(0)
	
	if has_node("/root/Start Screen/Start Lights"):
		light_ref = get_node("/root/Start Screen/Start Lights")
		light_ref.light_level.connect(_start_game)
	
func _process(delta: float) -> void:
	if start_game == true:
		velocity.x = MOVE_SPEED
		animator.play("walk_right")
	move_and_slide()
	pass

func _start_game()->void:
	start_game = true
