extends CharacterBody2D

@export var speed := 100.0
@export var distance := 300.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var direction := 1
var start_position: Vector2


func _ready() -> void:
	start_position = global_position


func _physics_process(delta: float) -> void:
	velocity.x = direction * speed

	animated_sprite.flip_h = direction < 0

	move_and_slide()

	# يرجع عندما يصل للمسافة المحددة
	if abs(global_position.x - start_position.x) >= distance:
		direction *= -1
