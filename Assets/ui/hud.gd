extends Control


@onready var hp_label: Label = $VBoxContainer/HP
@onready var damage_label: Label = $VBoxContainer/Damage
@onready var score_label: Label = $VBoxContainer/Score
@onready var lives_label: Label = $VBoxContainer/Lives
@onready var bonus_label: Label = $VBoxContainer/Bonus


func _process(_delta: float) -> void:

	var player = get_tree().get_first_node_in_group("player")

	if player == null:
		return


	hp_label.text = "HP: " + str(player.health) + " / " + str(player.max_health)

	damage_label.text = "Damage Bonus: +" + str(player.damage_bonus)

	score_label.text = "Score: " + str(player.score)

	lives_label.text = "Lives: " + str(player.lives)

	bonus_label.text = "Bonus: +" + str(player.damage_bonus)
