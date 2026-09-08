extends Area2D

@export_file("*.tscn") var next_level: String


func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Soot":
		call_deferred("_go_to_level_2")

func _go_to_level_2():
	get_tree().change_scene_to_file(next_level)
