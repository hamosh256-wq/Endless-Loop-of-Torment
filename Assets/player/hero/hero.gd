extends CharacterBody2D


# =========================
# PLAYER SETTINGS
# =========================

@export var walk_speed := 150.0
@export var run_speed := 280.0
@export var jump_velocity := -450.0
@export var gravity := 1000.0

@onready var sword_sound: AudioStreamPlayer2D = $swordsound
@onready var death_sound: AudioStreamPlayer2D = $death
@onready var jump_sound: AudioStreamPlayer2D = $jump


# =========================
# PLAYER STATS
# =========================

@export var max_health := 100
var health := 100

var damage_bonus := 10
var score := 0
var lives := 3


# =========================
# NODES
# =========================

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var body_collision: CollisionShape2D = $CollisionShape2D

# مجموعة مناطق الهجوم
@onready var attack_direction: Node2D = $AttackDirection

# SWORDS
@onready var sword1 = $AttackDirection/sword
@onready var sword2 = $AttackDirection/sword2
@onready var sword3 = $AttackDirection/sword3

@onready var sword1_collision = $AttackDirection/sword/CollisionShape2D
@onready var sword2_collision = $AttackDirection/sword2/CollisionShape2D
@onready var sword3_collision = $AttackDirection/sword3/CollisionShape2D


# =========================
# STATES
# =========================

var facing_right := true

var attacking := false
var defending := false
var protecting := false
var hurt := false
var dead := false

var spawn_position: Vector2

var combo := 0
var combo_queued := false

var facing_direction := 1


func add_score(amount: int) -> void:
	score += amount
	print("SCORE: ", score)


# =========================
# DAMAGE PROTECTION
# =========================

var invincible := false
var invincible_time := 0.5


# =========================================================
# READY
# =========================================================

func _ready() -> void:

	disable_all_swords()

	health = max_health

	spawn_position = global_position


# =========================================================
# MAIN PROCESS
# =========================================================

func _physics_process(delta: float) -> void:

	if dead:
		return


	# =========================
	# GRAVITY
	# =========================

	if not is_on_floor():
		velocity.y += gravity * delta


	# =========================
	# ATTACK STATE
	# =========================

	if attacking:

		if Input.is_action_just_pressed("attack"):
			combo_queued = true

		velocity.x = 0
		move_and_slide()
		return


	# =========================
	# HURT / PROTECT
	# =========================

	if hurt or protecting:

		velocity.x = 0
		move_and_slide()
		return


	# =========================
	# DEFEND
	# =========================

	if Input.is_action_pressed("defend"):

		defending = true
		velocity.x = 0
		animated_sprite.play("defend")

		move_and_slide()
		return

	else:

		defending = false


	# =========================
	# MOVEMENT
	# =========================

	var direction := Input.get_axis("left ", "right")


	if direction != 0:

		var current_speed = walk_speed


		# RUN
		if Input.is_action_pressed("run"):
			current_speed = run_speed


		velocity.x = direction * current_speed


		# =========================
		# FACING DIRECTION
		# =========================

		if direction > 0:

			facing_right = true
			facing_direction = 1

			# قلب الصورة
			animated_sprite.flip_h = false

			# مناطق الهجوم يمين
			attack_direction.scale.x = 1


		else:

			facing_right = false
			facing_direction = -1

			# قلب الصورة
			animated_sprite.flip_h = true

			# مناطق الهجوم يسار
			attack_direction.scale.x = -1


	else:

		velocity.x = move_toward(
			velocity.x,
			0,
			walk_speed
		)


	# =========================
	# JUMP
	# =========================

	if Input.is_action_just_pressed("jump") and is_on_floor():

		velocity.y = jump_velocity

		jump_sound.play()


	# =========================
	# ATTACK
	# =========================

	if Input.is_action_just_pressed("attack"):

		if velocity.x != 0:

			run_attack()

		else:

			start_attack()


	# =========================
	# PROTECT
	# =========================

	if Input.is_action_just_pressed("protect"):

		start_protect()


	# =========================
	# UPDATE ANIMATION
	# =========================

	update_animation()

	move_and_slide()


# =========================================================
# ANIMATIONS
# =========================================================

func update_animation() -> void:

	if attacking or hurt or dead or defending or protecting:
		return


	if not is_on_floor():

		animated_sprite.play("jump")


	elif velocity.x != 0:

		if Input.is_action_pressed("run"):

			animated_sprite.play("run")

		else:

			animated_sprite.play("walk")


	else:

		animated_sprite.play("idel")


# =========================================================
# ATTACK SYSTEM
# =========================================================

func start_attack() -> void:

	if attacking:
		return


	attacking = true
	combo = 1
	combo_queued = false

	attack_1()


# =========================================================
# RUN ATTACK
# =========================================================

func run_attack() -> void:

	if attacking:
		return


	attacking = true

	animated_sprite.play("run_attack")

	enable_sword1()

	await animated_sprite.animation_finished

	disable_all_swords()

	attacking = false


# =========================================================
# COMBO ATTACK 1
# =========================================================

func attack_1() -> void:

	animated_sprite.play("attack")

	sword_sound.play()

	enable_sword1()

	await animated_sprite.animation_finished

	disable_all_swords()


	if combo_queued:

		combo_queued = false

		attack_2()

	else:

		end_attack()


# =========================================================
# COMBO ATTACK 2
# =========================================================

func attack_2() -> void:

	animated_sprite.play("attack2")

	sword_sound.play()

	enable_sword2()

	await animated_sprite.animation_finished

	disable_all_swords()


	if combo_queued:

		combo_queued = false

		combo = 3

		attack_3()

	else:

		end_attack()


# =========================================================
# COMBO ATTACK 3
# =========================================================

func attack_3() -> void:

	animated_sprite.play("attack3")

	sword_sound.play()

	enable_sword3()

	await animated_sprite.animation_finished

	disable_all_swords()

	end_attack()


# =========================================================
# END ATTACK
# =========================================================

func end_attack() -> void:

	disable_all_swords()

	attacking = false

	combo = 0

	combo_queued = false


# =========================================================
# SWORD HITBOXES
# =========================================================

func disable_all_swords() -> void:

	sword1_collision.set_deferred("disabled", true)

	sword2_collision.set_deferred("disabled", true)

	sword3_collision.set_deferred("disabled", true)


func enable_sword1() -> void:

	disable_all_swords()

	await get_tree().process_frame

	sword1_collision.disabled = false


func enable_sword2() -> void:

	disable_all_swords()

	await get_tree().process_frame

	sword2_collision.disabled = false


func enable_sword3() -> void:

	disable_all_swords()

	await get_tree().process_frame

	sword3_collision.disabled = false


# =========================================================
# PROTECT
# =========================================================

func start_protect() -> void:

	if attacking or hurt:
		return


	protecting = true

	animated_sprite.play("protect")

	await animated_sprite.animation_finished

	protecting = false


# =========================================================
# DAMAGE SYSTEM
# =========================================================

func take_damage(damage: int) -> void:

	if dead or invincible:
		return


	invincible = true


	# تقليل الضرر أثناء الدفاع
	if defending:

		damage = int(damage / 2.0)


	health -= damage


	if health <= 0:

		die()

		return

	else:

		play_hurt()


	await get_tree().create_timer(invincible_time).timeout

	invincible = false


# =========================================================
# HURT
# =========================================================

func play_hurt() -> void:

	if hurt or dead:
		return


	hurt = true

	disable_all_swords()

	animated_sprite.play("hurt")

	await animated_sprite.animation_finished

	hurt = false


# =========================================================
# DEATH
# =========================================================

func die() -> void:

	if dead:
		return


	dead = true

	disable_all_swords()

	velocity = Vector2.ZERO

	death_sound.play()

	animated_sprite.play("dead")

	await animated_sprite.animation_finished


	lives -= 1

	print("LIVES LEFT: ", lives)


	global_position = spawn_position

	health = max_health

	velocity = Vector2.ZERO

	dead = false

	hurt = false

	attacking = false

	animated_sprite.play("idel")


# =========================================================
# SWORD DAMAGE
# =========================================================

func _on_sword_body_entered(body: Node2D) -> void:

	if body.is_in_group("enemy"):

		if body.has_method("take_damage"):

			body.take_damage(20 + damage_bonus)


func _on_sword_2_body_entered(body: Node2D) -> void:

	if body.is_in_group("enemy"):

		if body.has_method("take_damage"):

			body.take_damage(25 + damage_bonus)


func _on_sword_3_body_entered(body: Node2D) -> void:

	if body.is_in_group("enemy"):

		if body.has_method("take_damage"):

			body.take_damage(35 + damage_bonus)
