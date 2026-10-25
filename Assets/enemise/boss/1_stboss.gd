extends CharacterBody2D


# =========================================================
# SETTINGS
# =========================================================

@export var speed := 120.0
@export var max_health := 300

@export var attack_distance := 100.0
@export var attack_cooldown := 1.5
@export var detection_distance := 400.0


# =========================================================
# NODES
# =========================================================

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@onready var sword1: Area2D = $sword1
@onready var sword2: Area2D = $sword2
@onready var sword3: Area2D = $sword3


# =========================================================
# VARIABLES
# =========================================================

var health: int

var target: Node2D = null

var dead := false
var attacking := false
var hurt := false

var can_attack := true


# =========================================================
# READY
# =========================================================

func _ready() -> void:

	health = max_health

	animated_sprite.play("idel")

	# إيقاف جميع الـ Hitboxes بالبداية
	sword1.monitoring = false
	sword2.monitoring = false
	sword3.monitoring = false

	print("BOSS READY")

	print("PLAYERS FOUND: ", get_tree().get_nodes_in_group("player").size())
	print("ALLIES FOUND: ", get_tree().get_nodes_in_group("ally").size())


# =========================================================
# MAIN AI
# =========================================================

func _physics_process(_delta: float) -> void:

	if dead:
		return


	# البحث المستمر عن أقرب هدف
	find_target()


	# أثناء الهجوم أو تلقي الضربة
	if attacking or hurt:

		velocity = Vector2.ZERO
		move_and_slide()

		return


	# =====================================================
	# إذا يوجد هدف
	# =====================================================

	if target != null and is_instance_valid(target):

		var distance_to_target: float = global_position.distance_to(
			target.global_position
		)


		# الاتجاه نحو الهدف
		if target.global_position.x < global_position.x:

			velocity.x = -speed
			animated_sprite.flip_h = true

		else:

			velocity.x = speed
			animated_sprite.flip_h = false


		# =================================================
		# إذا قريب → يهاجم
		# =================================================

		if distance_to_target <= attack_distance:

			velocity.x = 0

			animated_sprite.play("idel")

			if can_attack:

				attack()


		# =================================================
		# إذا بعيد → يمشي نحوه
		# =================================================

		else:

			animated_sprite.play("walk")


	else:

		# لا يوجد هدف
		velocity.x = 0

		animated_sprite.play("idel")


	move_and_slide()


# =========================================================
# FIND TARGET
# =========================================================

func find_target() -> void:

	var closest_target: Node2D = null
	var closest_distance: float = detection_distance


	# =====================================================
	# البحث عن البطل
	# =====================================================

	var player_nodes = get_tree().get_nodes_in_group("player")

	for player_node in player_nodes:

		if player_node is Node2D:

			var distance_to_player: float = global_position.distance_to(
				player_node.global_position
			)

			if distance_to_player < closest_distance:

				closest_distance = distance_to_player
				closest_target = player_node


	# =====================================================
	# البحث عن الحلفاء
	# =====================================================

	var ally_nodes = get_tree().get_nodes_in_group("ally")

	for ally_node in ally_nodes:

		if ally_node is Node2D:

			var distance_to_ally: float = global_position.distance_to(
				ally_node.global_position
			)

			if distance_to_ally < closest_distance:

				closest_distance = distance_to_ally
				closest_target = ally_node


	target = closest_target


# =========================================================
# ATTACK SYSTEM
# =========================================================

func attack() -> void:

	if attacking or hurt or dead or not can_attack:
		return


	attacking = true
	can_attack = false

	velocity = Vector2.ZERO


	# اختيار هجمة عشوائية
	var attack_number = randi_range(1, 3)


	match attack_number:

		1:
			await attack_1()

		2:
			await attack_2()

		3:
			await attack_3()


	# انتهاء الهجوم
	if not dead:

		attacking = false


	# Cooldown
	await get_tree().create_timer(attack_cooldown).timeout


	if not dead:

		can_attack = true


# =========================================================
# ATTACK 1
# =========================================================

func attack_1() -> void:

	print("BOSS ATTACK 1")

	animated_sprite.play("attack1")


	# انتظار قبل الضربة
	await get_tree().create_timer(0.2).timeout


	if dead or hurt:
		return


	sword1.monitoring = true


	# مدة الـ Hitbox
	await get_tree().create_timer(0.3).timeout


	sword1.monitoring = false


	await get_tree().create_timer(0.3).timeout


# =========================================================
# ATTACK 2
# =========================================================

func attack_2() -> void:

	print("BOSS ATTACK 2")

	animated_sprite.play("attack2")


	await get_tree().create_timer(0.2).timeout


	if dead or hurt:
		return


	sword2.monitoring = true


	await get_tree().create_timer(0.3).timeout


	sword2.monitoring = false


	await get_tree().create_timer(0.3).timeout


# =========================================================
# ATTACK 3
# =========================================================

func attack_3() -> void:

	print("BOSS ATTACK 3")

	animated_sprite.play("atack3")


	await get_tree().create_timer(0.3).timeout


	if dead or hurt:
		return


	sword3.monitoring = true


	await get_tree().create_timer(0.4).timeout


	sword3.monitoring = false


	await get_tree().create_timer(0.3).timeout


# =========================================================
# SWORD 1 HIT
# =========================================================

func _on_sword_1_body_entered(body: Node2D) -> void:

	if body.is_in_group("player") or body.is_in_group("ally"):

		if body.has_method("take_damage"):

			print("SWORD 1 HIT: ", body.name)

			body.take_damage(20)


# =========================================================
# SWORD 2 HIT
# =========================================================

func _on_sword_2_body_entered(body: Node2D) -> void:

	if body.is_in_group("player") or body.is_in_group("ally"):

		if body.has_method("take_damage"):

			print("SWORD 2 HIT: ", body.name)

			body.take_damage(25)


# =========================================================
# SWORD 3 HIT
# =========================================================

func _on_sword_3_body_entered(body: Node2D) -> void:

	if body.is_in_group("player") or body.is_in_group("ally"):

		if body.has_method("take_damage"):

			print("SWORD 3 HIT: ", body.name)

			body.take_damage(35)


# =========================================================
# DAMAGE SYSTEM
# =========================================================

func take_damage(damage_amount: int) -> void:

	if dead:
		return


	health -= damage_amount

	print("BOSS HEALTH: ", health)


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

	attacking = false

	velocity = Vector2.ZERO


	# إيقاف جميع الأسلحة
	sword1.monitoring = false
	sword2.monitoring = false
	sword3.monitoring = false


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
	attacking = false
	hurt = false

	velocity = Vector2.ZERO


	# إيقاف جميع الـ Hitboxes
	sword1.monitoring = false
	sword2.monitoring = false
	sword3.monitoring = false


	print("BOSS DEAD!")


	animated_sprite.play("die")


	await get_tree().create_timer(1.5).timeout


	queue_free()
