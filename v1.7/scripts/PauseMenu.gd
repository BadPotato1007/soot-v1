extends CanvasLayer

@onready var resume_button: Button = $DimBackground/CRTFrame/MenuContent/ResumeButton
@onready var quit_button: Button = $DimBackground/CRTFrame/MenuContent/QuitButton

func _ready() -> void:
	# Ensures this menu always processes input even when get_tree().paused = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	
	resume_button.pressed.connect(_on_resume_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _input(event: InputEvent) -> void:
	# Checks both standard ui_cancel AND physical Escape key directly
	var is_escape_key := false
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE or event.physical_keycode == KEY_ESCAPE:
			is_escape_key = true
	
	if event.is_action_pressed("ui_cancel") or is_escape_key:
		get_viewport().set_input_as_handled()
		toggle_pause()

func toggle_pause() -> void:
	if get_tree().paused:
		resume_game()
	else:
		pause_game()

func pause_game() -> void:
	get_tree().paused = true
	visible = true
	resume_button.grab_focus()

func resume_game() -> void:
	get_tree().paused = false
	visible = false

func _on_resume_pressed() -> void:
	resume_game()

func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().quit()
