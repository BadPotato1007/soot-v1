extends Area2D

@export var speed: float = 240.0
@export var max_lifetime: float = 4.0
var is_player_bullet: bool = false
var elapsed: float = 0.0

func _ready() -> void:
	add_to_group("bullets")
	body_entered.connect(_on_body_entered)
	if has_node("ColorRect"):
		$ColorRect.color = Color.BLACK if is_player_bullet else Color(1.0, 0.08, 0.16)
		
		
func _physics_process(delta: float) -> void:
	position += transform.x * speed * delta
	elapsed += delta
	if elapsed > max_lifetime:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if is_player_bullet and body.is_in_group("enemies"):
		body.shatter()
		queue_free()
	elif is_player_bullet and body.is_in_group("red_core"):
		# Check if core is vulnerable
		if body.has_meta("vulnerable") and body.get_meta("vulnerable") == true:
			var level = get_tree().current_scene
			if level and level.has_method("destroy_core_and_transition"):
				level.destroy_core_and_transition()
		else:
			ScreenShake.shake(2.0, 10.0)
		queue_free()
	elif not is_player_bullet and body.is_in_group("player"):
		body.die()
		queue_free()
	elif body.is_in_group("walls"):
		ScreenShake.shake(1.0, 14.0)
		queue_free()
