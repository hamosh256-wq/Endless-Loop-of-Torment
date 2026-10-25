extends Area2D


# =========================================================
# SETTINGS
# =========================================================

@export var speed := 250.0
@export var damage := 30

@export var life_time := 5.0


# =========================================================
# NODES
# =========================================================

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


# =========================================================
# VARIABLES
# =========================================================

var direction := 1

var exploded := false


# =========================================================
# READY
# =========================================================

func _ready() -> void:

	animated_sprite.play("fly")

	# حذف الضربة تلقائياً بعد 5 ثواني
	await get_tree().create_timer(life_time).timeout

	if not exploded:

		queue_free()


# =========================================================
# MOVEMENT
# =========================================================

func _physics_process(delta: float) -> void:

	if exploded:
		return


	position.x += direction * speed * delta


# =========================================================
# HIT
# =========================================================

func _on_body_entered(body: Node2D) -> void:

	if exploded:
		return


	if body.is_in_group("player") or body.is_in_group("ally"):

		explode()

		if body.has_method("take_damage"):

			body.take_damage(damage)


# =========================================================
# EXPLOSION
# =========================================================

func explode() -> void:

	if exploded:
		return


	exploded = true

	speed = 0


	animated_sprite.play("explod")


	await animated_sprite.animation_finished


	queue_free()
