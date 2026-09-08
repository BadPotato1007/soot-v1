extends Area2D

@export var speed: float = 300.0

func _ready() -> void:
	add_to_group("obstacle")

func _process(delta: float) -> void:
	position.x -= speed * delta

	if position.x < -100:
		queue_free()


func _on_body_entered(body):
	if body.name == "Soot_Act2" or body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(1)
