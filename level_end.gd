extends Area2D

@export var next_level: String = "res://level_2.tscn"

var player_inside := false


func _process(_delta: float) -> void:

	if not player_inside:
		return


	var enemies = get_tree().get_nodes_in_group("enemy")

	if enemies.size() == 0:

		get_tree().change_scene_to_file(next_level)


func _on_body_entered(body: Node2D) -> void:

	if body.is_in_group("player"):

		player_inside = true


func _on_body_exited(body: Node2D) -> void:

	if body.is_in_group("player"):

		player_inside = false
