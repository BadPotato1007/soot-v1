extends Node

const MIN_TIME_SCALE: float = 0.05
const MAX_TIME_SCALE: float = 1.0

var player_is_acting: bool = false
var is_frozen: bool = false
var slow_motion_enabled: bool = false

func _process(delta: float) -> void:
	if is_frozen:
		return

	var target = MIN_TIME_SCALE if slow_motion_enabled and not player_is_acting else MAX_TIME_SCALE
	Engine.time_scale = lerpf(Engine.time_scale, target, 0.25)
	AudioServer.playback_speed_scale = maxf(0.2, Engine.time_scale)

func set_slow_motion_enabled(enabled: bool) -> void:
	slow_motion_enabled = enabled
	player_is_acting = false
	Engine.time_scale = MAX_TIME_SCALE
	AudioServer.playback_speed_scale = MAX_TIME_SCALE

func trigger_impact_freeze(duration_real_seconds: float = 0.05) -> void:
	is_frozen = true
	Engine.time_scale = 0.02
	# Use a real-time (unscaled) scene tree timer so it never gets stuck!
	await get_tree().create_timer(duration_real_seconds, true, false, true).timeout
	is_frozen = false
