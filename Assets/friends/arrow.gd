extends Area2D

@export var speed := 500.0
@export var damage := 20

var direction := Vector2.RIGHT


func _physics_process(delta: float) -> void:

	position += direction * speed * delta


func _on_body_entered(body: Node2D) -> void:

	if body.is_in_group("enemy"):

		if body.has_method("take_damage"):
			body.take_damage(damage)

		queue_free()
