extends CharacterBody2D

const SPEED = 100.0
const JUMP_FORCE = 215.0
const GRAVITY = 650.0

@onready var animated_sprite = $AnimatedSprite2D


func _physics_process(delta):

	# Gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Jump
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = -JUMP_FORCE

	# Movement
	var direction = Input.get_axis("ui_left", "ui_right")

	if direction:
		velocity.x = direction * SPEED
		animated_sprite.play("walk")
		animated_sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		animated_sprite.stop()

	move_and_slide()
