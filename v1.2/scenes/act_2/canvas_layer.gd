extends CanvasLayer

@onready var quit_button: Button = $VBoxContainer/Button2


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("damage_overlay")
	


func _on_retry_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_quit_pressed() -> void:
	get_tree().quit()
