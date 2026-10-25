extends Area2D


@export var score_value := 1
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

		print("COIN COLLECTED! +", score_value)


		# إضافة السكور
		# عدل هذا حسب نظام السكور عندك
		if body.has_method("add_score"):
			body.add_score(score_value)


		# تشغيل الصوت
		audio_player.play()


		# إخفاء الكوين
		hide()


		# ننتظر الصوت ثم نحذفها
		await audio_player.finished

		queue_free()
