extends Control


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://the actual game/lv_1.tscn")





func _on_exite_pressed() -> void:
	get_tree().quit()
