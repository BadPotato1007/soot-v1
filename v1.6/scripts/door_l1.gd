extends Area2D

@export_file("*.tscn") var next_level: String


func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Soot":
		call_deferred("_go_to_level_2")

func _go_to_level_2() -> void:
	# Bypasses the node's local tree to prevent the null error
	var tree = Engine.get_main_loop() as SceneTree
	
	if tree:
		var error = tree.change_scene_to_file(next_level)
		if error != OK:
			push_error("Failed to load scene: ", next_level, " Error code: ", error)
	else:
		push_error("Could not access the main SceneTree loop.")
