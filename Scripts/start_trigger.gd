extends Area2D

var player_ref
var start_game = false

var GAME_SCENE

func _ready() -> void:
	player_ref = get_node("/root/Start Screen/Start Alan")

func _process(delta: float) -> void:
	if start_game:
		get_tree().change_scene_to_file("res://Scenes/Level.tscn")

func _on_body_entered(body: Node2D) -> void:
	if body.name == player_ref.name:
		print("Trying to change the scene")
		start_game = true
