extends CharacterBody2D

@export var SPEED = 100.0
@export var JUMP_FORCE = 215.0
@export var GRAVITY = 650.0

@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	_on_animated_sprite_2d_frame_changed()
	
func _on_animated_sprite_2d_frame_changed():
	var current_frame = animated_sprite.frame
	for child in get_children():
		if child is CollisionPolygon2D:
			child.disabled = true
	var polygon = get_node("frame_" + str(current_frame))
	polygon.disabled = false

func _physics_process(delta):

	# Gravity
	if not is_on_floor():
		velocity -= up_direction * GRAVITY * delta

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
		
	animated_sprite.flip_v = (up_direction == Vector2.DOWN)

	move_and_slide()
