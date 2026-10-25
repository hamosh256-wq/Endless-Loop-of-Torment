extends Area2D

@export_file("*.tscn") var next_level: String

var player_inside := false
var changing_level := false


func _process(_delta: float) -> void:

	if not player_inside:
		return

	var enemies = get_tree().get_nodes_in_group("enemy")

	if enemies.size() == 0 and not changing_level:

		changing_level = true

		print("ALL ENEMIES DEAD! GOING TO NEXT LEVEL")

		get_tree().change_scene_to_file(next_level)


func _on_body_entered(body: Node2D) -> void:

	if body.is_in_group("player"):

		player_inside = true


func _on_body_exited(body: Node2D) -> void:

	if body.is_in_group("player"):

		player_inside = false
