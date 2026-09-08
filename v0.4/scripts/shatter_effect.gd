extends Node2D

var shard_color: Color = Color(1.0, 0.08, 0.16)

class Shard:
	var pos: Vector2
	var vel: Vector2
	var rot: float
	var rot_speed: float
	var points: PackedVector2Array
	var alpha: float = 1.0

var shards: Array[Shard] = []

func _ready() -> void:
	# Spawn 14 sharp geometric glass pieces
	for i in range(14):
		var s = Shard.new()
		s.pos = Vector2.ZERO
		var angle = randf_range(0, TAU)
		var speed = randf_range(80.0, 180.0)
		s.vel = Vector2.RIGHT.rotated(angle) * speed
		s.rot = randf_range(0, TAU)
		s.rot_speed = randf_range(-15.0, 15.0)

		# Random crystalline triangular shape
		var p1 = Vector2(randf_range(-4, -1), randf_range(-4, -1))
		var p2 = Vector2(randf_range(2, 6), randf_range(-3, 2))
		var p3 = Vector2(randf_range(-2, 3), randf_range(2, 6))
		s.points = PackedVector2Array([p1, p2, p3])
		shards.append(s)

func _process(delta: float) -> void:
	var any_alive = false
	for s in shards:
		s.pos += s.vel * delta
		s.rot += s.rot_speed * delta
		s.vel = s.vel.lerp(Vector2.ZERO, 3.5 * delta) # Floor friction
		s.alpha -= 0.35 * delta
		if s.alpha > 0.0:
			any_alive = true

	queue_redraw()

	if not any_alive:
		queue_free()

func _draw() -> void:
	for s in shards:
		if s.alpha <= 0.0:
			continue
		var col = shard_color
		col.a = clampf(s.alpha, 0.0, 1.0)
		
		# Draw rotated polygon shard
		var transformed_pts = PackedVector2Array()
		for pt in s.points:
			transformed_pts.append(s.pos + pt.rotated(s.rot))
		draw_colored_polygon(transformed_pts, col)
		
		# White specular highlight line on the edge
		draw_line(transformed_pts[0], transformed_pts[1], Color(1, 1, 1, col.a * 0.7), 1.0)
