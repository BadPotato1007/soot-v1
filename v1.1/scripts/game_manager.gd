extends Node

var current_level_index: int = 7
const TOTAL_LEVELS: int = 8

signal level_changed(index: int)
signal enemy_killed(remaining: int)

func restart_current_level() -> void:
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()

func next_level() -> void:
	current_level_index = (current_level_index + 1) % TOTAL_LEVELS
	Engine.time_scale = 1.0
	level_changed.emit(current_level_index)
