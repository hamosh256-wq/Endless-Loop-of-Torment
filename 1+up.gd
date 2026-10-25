extends Area2D


@export var life_value := 1
@export var health_bonus := 50

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

var collected := false


func _ready() -> void:

	animated_sprite.play()


func _on_body_entered(body: Node2D) -> void:

	if collected:
		return


	if body.is_in_group("player"):

		collected = true

		print("LIFE +", life_value)


		# =========================
		# إضافة حياة
		# =========================

		if body.has_method("add_life"):

			body.add_life(life_value)


		# =========================
		# زيادة Max HP
		# =========================

		if "max_health" in body:

			body.max_health += health_bonus
			body.health += health_bonus

			print("MAX HEALTH: ", body.max_health)


		# تشغيل صوت 1-UP
		audio_player.play()


		# إخفاء القلب
		hide()


		await audio_player.finished


		queue_free()
