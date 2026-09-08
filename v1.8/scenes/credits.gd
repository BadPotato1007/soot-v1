extends Control

# Drag and drop your target UI scene file here in the Inspector
@export_file("*.tscn") var target_scene_path: String = "res://scenes/end.tscn"

# The duration of the timeout in seconds (1 minute)
@export var timeout_duration: float = 60.0

var transition_timer: Timer

func _ready() -> void:
	setup_timeout_timer()

func setup_timeout_timer() -> void:
	transition_timer = Timer.new()
	add_child(transition_timer)
	
	transition_timer.wait_time = timeout_duration
	transition_timer.one_shot = true
	transition_timer.timeout.connect(_on_timeout)
	transition_timer.start()

func _on_timeout() -> void:
	print("Time is up! Changing scene...")
	change_scene()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		print("Key pressed! Overriding timer...")
		change_scene()

func change_scene() -> void:
	if is_instance_valid(transition_timer):
		transition_timer.stop()
		
	if target_scene_path == "":
		print("Error: Target scene path is not set in the inspector!")
		return
		
	var error = get_tree().change_scene_to_file(target_scene_path)
	if error != OK:
		print("Failed to change scene. Error code: ", error)
