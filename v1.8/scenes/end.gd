extends Control

# Prevents the game from trying to quit twice simultaneously
var is_exiting: bool = false

func _ready() -> void:
	# Start the 30-second timer
	await get_tree().create_timer(30.0).timeout
	close_game()

# This built-in function triggers whenever the player presses a key or clicks
func _input(event: InputEvent) -> void:
	if event.is_pressed():
		close_game()

func close_game() -> void:
	if not is_exiting:
		is_exiting = true
		get_tree().quit()
