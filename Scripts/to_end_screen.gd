extends Area2D

var player_ref
var timer = false
var countdown = 0

const TO_END_SCREEN = 1.5

func _ready() -> void:
	player_ref = get_node("/root/Level/Alan")

func _process(delta: float) -> void:
	if timer == true:
		countdown += delta
		
	if countdown >= TO_END_SCREEN:
		get_tree().change_scene_to_file("res://Scenes/End Screen.tscn")
		
# when area is entered, change scene to end screen
func _on_body_entered(body: Node2D) -> void:
	if body.name == player_ref.name:
		timer = true
