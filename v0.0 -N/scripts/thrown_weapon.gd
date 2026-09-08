extends Area2D

@export var flight_speed: float = 270.0
var throw_direction: Vector2 = Vector2.RIGHT
var is_flying: bool = true

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	if is_flying:
		position += throw_direction * flight_speed * delta
		rotation += 20.0 * delta
		flight_speed = lerpf(flight_speed, 0.0, 3.5 * delta)
		if flight_speed < 15.0:
			is_flying = false

func _on_body_entered(body: Node2D) -> void:
	if is_flying and body.is_in_group("enemies"):
		body.shatter()
		is_flying = false
	elif body.is_in_group("walls"):
		is_flying = false