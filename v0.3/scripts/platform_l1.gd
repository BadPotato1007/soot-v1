extends StaticBody2D

# Tile size in pixels (e.g., 16 for 16x16 tiles)
const TILE_SIZE = 16 

# Vector2i(Atlas X, Atlas Y) of the tile texture in your TileSet
const TILE_ATLAS_COORD = Vector2i(0, 0)

# Source ID from your TileSet (usually 0)
const TILE_SOURCE_ID = 0 

@export var size: Vector2 = Vector2(50, 8):
	set(value):
		size = value
		update_platform()


func _ready():
	update_platform()


func update_platform():
	# 1. Update Collision Shape
	var shape = $CollisionShape2D.shape

	if shape == null:
		shape = RectangleShape2D.new()
		$CollisionShape2D.shape = shape

	shape.size = size

	# 2. Update Visual Polygon (Optional - remove if only using TileMap)
	if has_node("Polygon2D"):
		$Polygon2D.polygon = PackedVector2Array([
			Vector2(-size.x / 2, -size.y / 2),
			Vector2(size.x / 2, -size.y / 2),
			Vector2(size.x / 2, size.y / 2),
			Vector2(-size.x / 2, size.y / 2)
		])

	# 3. Update TileMap
	if has_node("TileMap"):
		_fill_tilemap($TileMap)


func _fill_tilemap(tilemap: TileMap):
	tilemap.clear()

	# Calculate how many tiles fit inside 'size'
	var cols = int(size.x / TILE_SIZE)
	var rows = int(size.y / TILE_SIZE)

	# Calculate starting grid position so tiles remain centered with CollisionShape2D
	@warning_ignore("integer_division")
	var start_x = -cols / 2
	@warning_ignore("integer_division")
	var start_y = -rows / 2

	# Fill grid with tiles
	for x in range(cols):
		for y in range(rows):
			var cell_coords = Vector2i(start_x + x, start_y + y)
			# In Godot 4, use set_cell on layer 0:
			tilemap.set_cell(0, cell_coords, TILE_SOURCE_ID, TILE_ATLAS_COORD)
