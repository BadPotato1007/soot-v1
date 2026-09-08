extends CanvasLayer

func _ready() -> void:
	hide() # Start hidden globally

# Call this function from your player script or level manager
func toggle_pause() -> void:
	var current_state = get_tree().paused
	get_tree().paused = !current_state
	visible = !current_state

func _on_resume_button_pressed() -> void:
	toggle_pause()

func _on_quit_button_pressed() -> void:
	get_tree().quit()
