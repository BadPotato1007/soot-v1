extends AnimatableBody2D

@export var speed: float = 300.0

func _ready() -> void:
	add_to_group("obstacle")
	
	# CRITICAL FIX: Tells Godot to ignore the frame-skip math from spawning
	if has_method("reset_physics_interpolation"):
		reset_physics_interpolation()

func _physics_process(delta: float) -> void:
	# CRITICAL FIX: All solid movement MUST happen inside physics process
	position.x -= speed * delta

	if position.x < -100:
		queue_free()
