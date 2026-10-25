extends CharacterBody2D


# =========================================================
# SETTINGS
# =========================================================

@export var speed := 100.0
@export var distance := 300.0

@export var max_health := 80
@export var volt_scene: PackedScene

@export var attack_cooldown := 2.0


# =========================================================
# NODES
# =========================================================

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea


# =========================================================
# VARIABLES
# =========================================================

var health: int

var direction := 1
var start_position: Vector2

var attacking := false
var hurt := false
var dead := false

var target: Node2D = null
var can_attack := true


# =========================================================
# READY
# =========================================================

func _ready() -> void:

	start_position = global_position

	health = max_health

	animated_sprite.play("idel")

	print("FLYING DEMON READY")


# =========================================================
# MAIN PROCESS
# =========================================================

func _physics_process(_delta: float) -> void:

	if dead:
		return


	if attacking or hurt:

		velocity = Vector2.ZERO
		move_and_slide()
		return


	# =====================================================
	# إذا يوجد هدف
	# =====================================================

	if target != null and is_instance_valid(target):

		# حساب مكان الهدف
		var distance_to_target = global_position.distance_to(target.global_position)


		# تحديد الاتجاه نحو الهدف
		if target.global_position.x < global_position.x:

			direction = -1

		else:

			direction = 1


		animated_sprite.flip_h = direction < 0


		# إذا الهدف قريب كفاية → هجوم
		if distance_to_target <= 250.0:

			velocity = Vector2.ZERO

			if can_attack:

				attack()

		else:

			# إذا بعيد → اقترب منه
			velocity.x = direction * speed


		move_and_slide()
		return


	# =====================================================
	# الحركة العادية
	# =====================================================

	velocity.x = direction * speed

	animated_sprite.flip_h = direction < 0

	animated_sprite.play("idel")

	move_and_slide()


	if abs(global_position.x - start_position.x) >= distance:

		direction *= -1


	# =====================================================
	# الحركة العادية
	# =====================================================

	velocity.x = direction * speed

	animated_sprite.flip_h = direction < 0

	animated_sprite.play("idel")

	move_and_slide()


	# تغيير الاتجاه
	if abs(global_position.x - start_position.x) >= distance:

		direction *= -1


# =========================================================
# DETECTION
# =========================================================

func _on_detection_area_body_entered(body: Node2D) -> void:

	if body.is_in_group("players"):

		target = body

		print("TARGET FOUND: ", body.name)


func _on_detection_area_body_exited(body: Node2D) -> void:

	if body == target:

		target = null

		print("TARGET LOST")


# =========================================================
# ATTACK
# =========================================================

func attack() -> void:

	if attacking or hurt or dead or not can_attack:
		return


	attacking = true
	can_attack = false

	velocity = Vector2.ZERO

	print("FLYING DEMON ATTACK!")

	animated_sprite.play("attack")


	await get_tree().create_timer(0.4).timeout


	if not dead and target != null and is_instance_valid(target):

		shoot_volt()


	await get_tree().create_timer(0.8).timeout


	attacking = false


	await get_tree().create_timer(attack_cooldown).timeout


	can_attack = true


# =========================================================
# SHOOT VOLT
# =========================================================

func shoot_volt() -> void:

	print("SHOOTING VOLT")

	if volt_scene == null:

		print("ERROR: VOLT SCENE IS EMPTY")
		return


	var volt = volt_scene.instantiate()

	get_parent().add_child(volt)

	volt.global_position = global_position


	if "direction" in volt:

		volt.direction = direction


# =========================================================
# DAMAGE SYSTEM
# =========================================================

func take_damage(damage_amount: int) -> void:

	if dead:
		return


	health -= damage_amount

	print("FLYING DEMON HEALTH: ", health)


	if health <= 0:

		die()

	else:

		play_hurt()


# =========================================================
# HURT
# =========================================================

func play_hurt() -> void:

	if hurt or dead:
		return


	hurt = true

	velocity = Vector2.ZERO

	animated_sprite.play("hit")

	await get_tree().create_timer(0.4).timeout


	if not dead:

		hurt = false


# =========================================================
# DEATH
# =========================================================

func die() -> void:

	if dead:
		return


	dead = true

	velocity = Vector2.ZERO

	print("FLYING DEMON DEAD!")

	animated_sprite.play("die")

	await get_tree().create_timer(1.0).timeout

	queue_free()
