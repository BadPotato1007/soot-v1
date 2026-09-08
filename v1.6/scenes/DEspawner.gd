extends Node2D

# Preload your label scene
var label_scene = preload("res://scenes/spawning_label.tscn")

@onready var timer = $Timer

func _ready() -> void:
	# Connect the timer timeout signal to our spawn function
	timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout() -> void:
	# 1. Instantiate the packed scene
	var new_label = label_scene.instantiate() as Label
	
	# 2. Set custom text or randomized properties
	new_label.text = "Spawned Text!"
	
	# 3. Give it a random or specific position
	new_label.position = Vector2(randf_range(100, 500), randf_range(100, 400))
	
	# 4. Add the label as a child to the current scene tree
	get_tree().current_scene.add_child(new_label)
