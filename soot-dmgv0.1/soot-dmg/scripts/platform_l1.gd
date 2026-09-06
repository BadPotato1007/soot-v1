extends StaticBody2D

@export var size: Vector2 = Vector2(50, 8):
	set(value):
		size = value
		update_platform()


func _ready():
	update_platform()


func update_platform():

	# Collision
	var shape = $CollisionShape2D.shape

	if shape == null:
		shape = RectangleShape2D.new()
		$CollisionShape2D.shape = shape

	shape.size = size

	# Visual rectangle
	$Polygon2D.polygon = PackedVector2Array([
		Vector2(-size.x / 2, -size.y / 2),
		Vector2(size.x / 2, -size.y / 2),
		Vector2(size.x / 2, size.y / 2),
		Vector2(-size.x / 2, size.y / 2)
	])
