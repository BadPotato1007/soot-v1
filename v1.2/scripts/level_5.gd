extends Node2D

@export_file("*.tscn") var next_scene: String = "res://Scenes/act_2/level_1.tscn"

@onready var timer: Timer = $LevelTimer
@onready var ui_layer: CanvasLayer = $CanvasLayer
@onready var status_label: Label = $CanvasLayer/Label

func _ready() -> void:
	# Hide UI by default
	ui_layer.visible = false
	timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout() -> void:
	ui_layer.visible = true
	get_tree().paused = true
	
	await get_tree().create_timer(2.0, true, false, true).timeout
	
	get_tree().paused = false
	
	if ResourceLoader.exists(next_scene):
		get_tree().change_scene_to_file(next_scene)
	else:
		push_error("Target scene path not found: " + next_scene)
