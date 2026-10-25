extends Area2D


@export var expand_speed := 2.0
@export var max_scale := 3.0
@export var damage := 20


var current_scale := 1.0


func _ready() -> void:

	$AnimatedSprite2D.play()


func _physics_process(delta: float) -> void:

	current_scale += expand_speed * delta

	scale = Vector2(
		current_scale,
		current_scale
	)


	if current_scale >= max_scale:

		queue_free()


func _on_body_entered(body: Node2D) -> void:

	if body.is_in_group("player"):

		if body.has_method("take_damage"):

			body.take_damage(damage)

		queue_free()
