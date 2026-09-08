extends Node

var max_health: int = 3
var health: int = 3
var level_loops_left: int = 0
var level_repeats: int = 0

@export_file("*.tscn") var next_level_path: String = "res://Scenes/act_2/level_2.tscn"

func lose_health(amount: int = 1) -> bool:
	health -= amount
	if health <= 0:
		# Health depleted: Unpause, reset health for next level, and change scene
		get_tree().paused = false
		health = max_health
		
		# Call deferred to safely change scenes without physics lockup
		call_deferred("_go_to_next_level")
		return true # Game Over / Transition state triggered
	return false # Still has hearts left

func reset_game() -> void:
	health = max_health
	
func _go_to_next_level() -> void:
	if next_level_path != "":
		get_tree().change_scene_to_file(next_level_path)
	else:
		push_error("Next level path is not set in GameManager!")
