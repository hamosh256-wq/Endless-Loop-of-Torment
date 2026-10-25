extends CharacterBody2D


# =========================================================
# SETTINGS
# =========================================================
@onready var bow_sound: AudioStreamPlayer2D = $BowSound
@export var speed := 180.0

# المسافة التي يبقى فيها قريبًا من البطل
@export var follow_distance := 80.0

# مدى اكتشاف الأعداء
@export var enemy_detection_range := 400.0

# المسافة التي يبدأ منها إطلاق السهام
@export var attack_distance := 250.0

@export var max_health := 100
var health := 100


# =========================================================
# ARROW
# =========================================================

@export var arrow_scene: PackedScene


# =========================================================
# NODES
# =========================================================

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


# =========================================================
# VARIABLES
# =========================================================

var player: Node2D
var target_enemy: Node2D

var attacking := false
var hurt := false
var dead := false


# =========================================================
# READY
# =========================================================

func _ready() -> void:

	health = max_health

	

# =========================================================
# MAIN PROCESS
# =========================================================

func _physics_process(delta: float) -> void:

	if dead:
		return
	if player == null:
		player = get_tree().get_first_node_in_group("player")

	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta


	# لا يتحرك أثناء الضرب أو الإصابة
	if attacking or hurt:

		velocity.x = 0
		move_and_slide()
		return


	# البحث عن أقرب عدو
	find_enemy()


	# إذا وجد عدو
	if target_enemy != null and is_instance_valid(target_enemy):

		fight_enemy()

	else:

		follow_player()


# =========================================================
# FIND ENEMY
# =========================================================

func find_enemy() -> void:

	var enemies = get_tree().get_nodes_in_group("enemy")

	var closest_enemy: Node2D = null
	var closest_distance := enemy_detection_range


	for enemy in enemies:

		if not is_instance_valid(enemy):
			continue


		var distance = global_position.distance_to(enemy.global_position)


		if distance < closest_distance:

			closest_distance = distance
			closest_enemy = enemy


	target_enemy = closest_enemy


# =========================================================
# FOLLOW PLAYER
# =========================================================

func follow_player() -> void:

	if player == null:
		return


	var distance = global_position.distance_to(player.global_position)


	# إذا بعيد عن البطل
	if distance > follow_distance:

		var direction = (
			player.global_position - global_position
		).normalized()


		velocity.x = direction.x * speed

		animated_sprite.play("walking")


		# اتجاه الشخصية
		if direction.x > 0:

			animated_sprite.flip_h = false

		elif direction.x < 0:

			animated_sprite.flip_h = true


	# إذا قريب من البطل
	else:

		velocity.x = 0

		animated_sprite.play("idel")


	move_and_slide()


# =========================================================
# FIGHT ENEMY
# =========================================================

func fight_enemy() -> void:

	if not is_instance_valid(target_enemy):

		target_enemy = null

		return


	var distance = global_position.distance_to(
		target_enemy.global_position
	)


	# إذا العدو بعيد، اقترب منه
	if distance > attack_distance:

		var direction = (
			target_enemy.global_position - global_position
		).normalized()


		velocity.x = direction.x * speed

		animated_sprite.play("walking")


		# اتجاه العدو
		if direction.x > 0:

			animated_sprite.flip_h = false

		elif direction.x < 0:

			animated_sprite.flip_h = true


	# إذا داخل مدى السهم
	else:

		velocity.x = 0

		if not attacking:

			attack_enemy()


	move_and_slide()


# =========================================================
# ATTACK ENEMY
# =========================================================

func attack_enemy() -> void:

	if attacking:
		return


	attacking = true

	velocity = Vector2.ZERO


	# Animation الشحن
	animated_sprite.play("charging")


	# انتظر قليلًا قبل إطلاق السهم
	await get_tree().create_timer(0.4).timeout


	shoot_arrow()


	# انتظر انتهاء الأنيميشن
	await animated_sprite.animation_finished


	attacking = false


# =========================================================
# SHOOT ARROW
# =========================================================

func shoot_arrow() -> void:
  
	if target_enemy == null:
		return
 

	if not is_instance_valid(target_enemy):
		return


	if arrow_scene == null:
		print("Arrow Scene غير موجودة!")
		return
	 
	bow_sound.play()


	# إنشاء سهم جديد
	var arrow_instance = arrow_scene.instantiate()


	# إضافته للمشهد الرئيسي
	get_parent().add_child(arrow_instance)


	# مكان ظهور السهم
	arrow_instance.global_position = global_position


	# اتجاه العدو
	var direction = (
		target_enemy.global_position - global_position
	).normalized()


	# إرسال الاتجاه إلى السهم
	arrow_instance.direction = direction


	# قلب السهم
	if direction.x < 0:

		arrow_instance.scale.x = -1


# =========================================================
# DAMAGE SYSTEM
# =========================================================

func take_damage(damage: int) -> void:

	if dead:
		return


	health -= damage


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

	animated_sprite.play("hurt")

	await animated_sprite.animation_finished

	hurt = false


# =========================================================
# DEATH
# =========================================================

func die() -> void:

	dead = true

	velocity = Vector2.ZERO

	animated_sprite.play("die")

	await animated_sprite.animation_finished

	queue_free()
