extends CharacterBody2D


# =========================================================
# SETTINGS
# =========================================================

@export var speed := 120.0
@export var detection_range := 300.0
@export var attack_distance := 55.0

@export var max_health := 100
@export var damage := 15

var health := 100


# =========================================================
# NODES
# =========================================================

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@onready var attack1_collision: CollisionShape2D = $"1st attack/CollisionShape2D"
@onready var attack2_collision: CollisionShape2D = $"2nd attack/CollisionShape2D"


# =========================================================
# STATES
# =========================================================

var target: Node2D = null

var attacking := false
var hurt := false
var dead := false

var invincible := false
var invincible_time := 0.5

# =========================================================
# READY
# =========================================================

func _ready() -> void:

	health = max_health

	# التأكد أن الـ CollisionShapes موجودة
	if attack1_collision == null:
		print("ERROR: Attack 1 CollisionShape2D NOT FOUND!")

	if attack2_collision == null:
		print("ERROR: Attack 2 CollisionShape2D NOT FOUND!")

	disable_attacks()


# =========================================================
# MAIN AI
# =========================================================

func _physics_process(_delta: float) -> void:

	if dead:
		return


	# أثناء الهجوم أو الضرر
	if attacking or hurt:

		velocity.x = 0
		move_and_slide()
		return


	# البحث عن أقرب هدف
	find_target()


	# إذا وجد هدف
	if target != null and is_instance_valid(target):

		chase_target()

	else:

		velocity.x = 0
		animated_sprite.play("ideal")


	move_and_slide()


# =========================================================
# FIND TARGET
# =========================================================

func find_target() -> void:

	var possible_targets: Array = []

	# البطل
	possible_targets.append_array(
		get_tree().get_nodes_in_group("player")
	)

	# الجندي الصديق
	possible_targets.append_array(
		get_tree().get_nodes_in_group("ally")
	)


	var closest_target: Node2D = null
	var closest_distance := detection_range


	for possible_target in possible_targets:

		if not is_instance_valid(possible_target):
			continue

		if not possible_target is Node2D:
			continue


		var distance := global_position.distance_to(
			possible_target.global_position
		)


		if distance < closest_distance:

			closest_distance = distance
			closest_target = possible_target


	target = closest_target


# =========================================================
# CHASE TARGET
# =========================================================

func chase_target() -> void:

	if target == null or not is_instance_valid(target):

		target = null
		return


	var distance := global_position.distance_to(
		target.global_position
	)


	# بعيد → امش نحوه
	if distance > attack_distance:

		var direction := (
			target.global_position - global_position
		).normalized()


		velocity.x = direction.x * speed

		animated_sprite.play("walk")


		# اتجاه العدو
		if direction.x > 0:

			animated_sprite.flip_h = false

		elif direction.x < 0:

			animated_sprite.flip_h = true


	# قريب → هاجم
	else:

		velocity.x = 0

		if not attacking:

			start_attack()


# =========================================================
# ATTACK SYSTEM
# =========================================================

func start_attack() -> void:

	if attacking or dead:
		return


	attacking = true


	# اختيار هجمة عشوائية
	var attack_choice := randi_range(1, 2)


	if attack_choice == 1:

		attack_1()

	else:

		attack_2()


# =========================================================
# ATTACK 1
# =========================================================

func attack_1() -> void:

	animated_sprite.play("attack1")

	enable_attack1()


	await animated_sprite.animation_finished


	disable_attacks()

	attacking = false


# =========================================================
# ATTACK 2
# =========================================================

func attack_2() -> void:

	animated_sprite.play("attack2")

	enable_attack2()


	await animated_sprite.animation_finished


	disable_attacks()

	attacking = false


# =========================================================
# ATTACK HITBOXES
# =========================================================

func disable_attacks() -> void:

	if attack1_collision != null:
		attack1_collision.set_deferred("disabled", true)

	if attack2_collision != null:
		attack2_collision.set_deferred("disabled", true)


func enable_attack1() -> void:

	disable_attacks()

	if attack1_collision != null:
		attack1_collision.set_deferred("disabled", false)


func enable_attack2() -> void:

	disable_attacks()

	if attack2_collision != null:
		attack2_collision.set_deferred("disabled", false)


# =========================================================
# DAMAGE SYSTEM
# =========================================================

func take_damage(damage_amount: int) -> void:

	if dead or invincible:
		return


	# منع استقبال ضربات متكررة بسرعة
	invincible = true


	health -= damage_amount


	if health <= 0:

		die()
		return


	play_hurt()


	# فترة حماية قصيرة
	await get_tree().create_timer(invincible_time).timeout

	invincible = false


	health -= damage_amount


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

	disable_attacks()

	animated_sprite.play("hit")


	await animated_sprite.animation_finished


	hurt = false


# =========================================================
# DEATH
# =========================================================

func die() -> void:

	if dead:
		return


	dead = true

	velocity = Vector2.ZERO

	disable_attacks()

	animated_sprite.play("fall")


	await animated_sprite.animation_finished


	queue_free()


# =========================================================
# ATTACK 1 DAMAGE
# =========================================================

func _on_st_attack_body_entered(body: Node2D) -> void:

	if body.is_in_group("player") or body.is_in_group("ally"):

		if body.has_method("take_damage"):

			body.take_damage(damage)


# =========================================================
# ATTACK 2 DAMAGE
# =========================================================

func _on_nd_attack_body_entered(body: Node2D) -> void:

	if body.is_in_group("player") or body.is_in_group("ally"):

		if body.has_method("take_damage"):

			body.take_damage(damage)
