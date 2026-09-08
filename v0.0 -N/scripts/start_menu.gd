extends Control

# Audio buses (fallback to AudioServer)
var master_bus_idx: int = 0

@onready var main_buttons_container: VBoxContainer = $CenterContainer/MainButtons
@onready var settings_panel: Panel = $SettingsPanel

# Settings Controls
@onready var master_slider: HSlider = $SettingsPanel/VBox/MasterVolume/Slider
@onready var fullscreen_check: CheckBox = $SettingsPanel/VBox/Fullscreen/CheckBox

# Buttons
@onready var start_btn: Button = $CenterContainer/MainButtons/StartButton
@onready var settings_btn: Button = $CenterContainer/MainButtons/SettingsButton
@onready var quit_btn: Button = $CenterContainer/MainButtons/QuitButton
@onready var back_btn: Button = $SettingsPanel/VBox/BackButton

func _ready() -> void:
	Engine.time_scale = 1.0
	settings_panel.visible = false
	main_buttons_container.visible = true

	master_bus_idx = AudioServer.get_bus_index("Master")

	# Initialize UI values from system state
	master_slider.value = db_to_linear(AudioServer.get_bus_volume_db(master_bus_idx))
	fullscreen_check.button_pressed = (DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN)

	# Connect buttons
	start_btn.pressed.connect(_on_start_pressed)
	settings_btn.pressed.connect(_on_settings_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)
	back_btn.pressed.connect(_on_back_pressed)

	# Connect settings sliders & toggles
	master_slider.value_changed.connect(_on_master_volume_changed)
	fullscreen_check.toggled.connect(_on_fullscreen_toggled)

	# Focus on start button for keyboard/controller navigation
	start_btn.grab_focus()

func _on_start_pressed() -> void:
	GameManager.current_level_index = 0
	get_tree().change_scene_to_file("res://scenes/runner.tscn")

func _on_settings_pressed() -> void:
	main_buttons_container.visible = false
	settings_panel.visible = true
	back_btn.grab_focus()

func _on_back_pressed() -> void:
	settings_panel.visible = false
	main_buttons_container.visible = true
	settings_btn.grab_focus()

func _on_quit_pressed() -> void:
	get_tree().quit()

# Audio & Graphic callbacks
func _on_master_volume_changed(val: float) -> void:
	var db = linear_to_db(clampf(val, 0.0001, 1.0))
	AudioServer.set_bus_volume_db(master_bus_idx, db)
	AudioServer.set_bus_mute(master_bus_idx, val <= 0.01)


func _on_shake_slider_changed(val: float) -> void:
	# Optional: Test shake when changing setting
	if get_node_or_null("/root/ScreenShake"):
		ScreenShake.shake(val * 4.0, 10.0)

func _on_fullscreen_toggled(button_pressed: bool) -> void:
	if button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if settings_panel.visible:
			_on_back_pressed()
