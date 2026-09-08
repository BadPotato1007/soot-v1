extends CharacterBody2D

const GRAVITY = 1500.0
const JUMP_VELOCITY = -400.0

@onready var sprite = $AnimatedSprite2D

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		# Play run animation when grounded
		sprite.play("run")

	# Handle Jump
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		sprite.play("jump")

	move_and_slide()
