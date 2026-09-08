extends Node

var shake_strength: float = 0.0
var shake_decay: float = 12.0
var target_camera: Camera2D = null

func _process(_delta: float) -> void:
	# Use get_process_delta_time() or real time so shake decays even if time is slowed down
	var real_dt = 1.0 / 60.0

	if shake_strength > 0.05:
		shake_strength = lerpf(shake_strength, 0.0, shake_decay * real_dt)
		if target_camera and is_instance_valid(target_camera):
			target_camera.offset = Vector2(
				randf_range(-shake_strength, shake_strength),
				randf_range(-shake_strength, shake_strength)
			)
	else:
		shake_strength = 0.0
		if target_camera and is_instance_valid(target_camera):
			target_camera.offset = Vector2.ZERO

func shake(strength: float, decay: float = 12.0) -> void:
	shake_strength = maxf(shake_strength, strength)
	shake_decay = decay
