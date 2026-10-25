extends CharacterBody2D


# =========================================================
# SETTINGS
# =========================================================

@export var speed := 100.0
@export var max_health := 250

@export var detection_distance := 500.0
@export var attack_distance := 250.0
@export var attack_cooldown := 2.0

@export var spell_scene: PackedScene
@onready var spell_sound: AudioStreamPlayer2D = $SpellSound

# =========================================================
# NODES
# =========================================================

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


# =========================================================
# VARIABLES
# =========================================================

var health: int

var target: Node2D = null

var dead := false
var attacking := false
var hurt := false

var can_attack := true

var direction := 1


# =========================================================
# READY
# =========================================================

func _ready() -> void:

	health = max_health

	animated_sprite.play("idel")

	print("2ND BOSS READY")


# =========================================================
# MAIN AI
# =========================================================

func _physics_process(_delta: float) -> void:

	if dead:
		return


	# البحث عن أقرب هدف
	find_target()


	# أثناء الهجوم أو تلقي ضربة
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


		# تحديد الاتجاه
		if target.global_position.x < global_position.x:

			direction = -1
			animated_sprite.flip_h = true

		else:

			direction = 1
			animated_sprite.flip_h = false


		# =================================================
		# قريب من مدى السحر → يهاجم
		# =================================================

		if distance_to_target <= attack_distance:

			velocity = Vector2.ZERO

			animated_sprite.play("idel")


			if can_attack:

				attack()


		# =================================================
		# بعيد → يتحرك نحو الهدف
		# =================================================

		else:

			velocity.x = direction * speed

			animated_sprite.play("move")


	else:

		velocity = Vector2.ZERO

		animated_sprite.play("idel")


	move_and_slide()


# =========================================================
# FIND TARGET
# =========================================================

func find_target() -> void:

	var closest_target: Node2D = null
	var closest_distance: float = detection_distance


	# البحث عن البطل
	var player_nodes = get_tree().get_nodes_in_group("player")

	for player_node in player_nodes:

		if player_node is Node2D:

			var distance_to_player: float = global_position.distance_to(
				player_node.global_position
			)

			if distance_to_player < closest_distance:

				closest_distance = distance_to_player
				closest_target = player_node


	# البحث عن الحلفاء
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
# ATTACK
# =========================================================

func attack() -> void:

	if attacking or hurt or dead or not can_attack:
		return


	attacking = true
	can_attack = false

	velocity = Vector2.ZERO

	print("2ND BOSS ATTACK")


	animated_sprite.play("attack")


	# وقت قبل إطلاق السحر
	await get_tree().create_timer(0.4).timeout


	if not dead and not hurt and target != null:

		shoot_spell()


	# انتظار انتهاء الهجوم
	await get_tree().create_timer(0.8).timeout


	if not dead:

		attacking = false


	# Cooldown
	await get_tree().create_timer(attack_cooldown).timeout


	if not dead:

		can_attack = true


# =========================================================
# SHOOT SPELL
# =========================================================

func shoot_spell() -> void:

	if spell_scene == null:

		print("ERROR: SPELL SCENE IS EMPTY")
		return
 
	spell_sound.play()

	var spell = spell_scene.instantiate()

	get_parent().add_child(spell)

	spell.global_position = global_position


	# إرسال الاتجاه للـ Spell
	if "direction" in spell:

		spell.direction = direction


	print("SPELL SHOT")


# =========================================================
# DAMAGE SYSTEM
# =========================================================

func take_damage(damage_amount: int) -> void:

	if dead:
		return


	health -= damage_amount

	print("2ND BOSS HEALTH: ", health)


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


	print("2ND BOSS DEAD!")


	animated_sprite.play("die")


	await get_tree().create_timer(1.5).timeout


	get_tree().change_scene_to_file ("res://the actual game/demo_end.tscn")
