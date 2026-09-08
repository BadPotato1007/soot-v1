class_name DesktopEnding
extends Control

@export_category("Character Setup")
## Drag and drop your character .tscn scene here in the Inspector!
@export var character_scene: PackedScene

@onready var recycle_bin: Control = $RecycleBin
@onready var black_screen: ColorRect = $BlackScreen

var character_instance: Node2D = null
var is_dragging_sprite: bool = false
var last_mouse_pos: Vector2 = Vector2.ZERO
var sprite_desktop_pos: Vector2 = Vector2(220, 90)

func _ready() -> void:
	Engine.time_scale = 1.0
	black_screen.visible = false

	# 1. First, check if you dropped your character directly into the scene tree in the editor!
	var existing_char = get_node_or_null("Character")
	if not existing_char:
		# Search for any child that is a 2D node and not the UI elements
		for child in get_children():
			if child is Node2D and child.name != "BlackScreen":
				existing_char = child
				break

	if existing_char:
		character_instance = existing_char
	elif character_scene:
		# 2. Otherwise instantiate from the Inspector slot
		character_instance = character_scene.instantiate()
		add_child(character_instance)
	else:
		# 3. Fallback placeholder so it's never empty
		character_instance = create_fallback_sprite()
		add_child(character_instance)

	character_instance.z_index = 10
	character_instance.position = sprite_desktop_pos
	
	# Start animation if AnimatedSprite2D
	var anim: AnimatedSprite2D = null
	if character_instance is AnimatedSprite2D:
		anim = character_instance
	else:
		anim = character_instance.find_child("*", true, false) as AnimatedSprite2D
	if anim:
		anim.play()

func create_fallback_sprite() -> Node2D:
	var root = Node2D.new()
	root.name = "FallbackSprite"
	var col = ColorRect.new()
	col.offset_left = -6
	col.offset_top = -12
	col.offset_right = 6
	col.offset_bottom = 12
	col.color = Color(0.1, 0.1, 0.12)
	root.add_child(col)
	return root

func _process(delta: float) -> void:
	if not is_instance_valid(character_instance) or black_screen.visible:
		return

	var bin_center = recycle_bin.position + (recycle_bin.size * 0.5)

	# Inescapable Drag Logic
	if is_dragging_sprite:
		var current_mouse = get_viewport().get_mouse_position()
		var mouse_delta = current_mouse - last_mouse_pos
		last_mouse_pos = current_mouse

		if mouse_delta.length_squared() > 0.01:
			var dir_to_bin = (bin_center - sprite_desktop_pos).normalized()
			var dot = mouse_delta.dot(dir_to_bin)

			if dot >= 0:
				# Moving toward bin: allow normal drag
				sprite_desktop_pos += mouse_delta
			else:
				# Trying to move away: reverse direction toward bin
				var move_distance = mouse_delta.length()
				sprite_desktop_pos += dir_to_bin * (move_distance * 0.9 + 1.5) * 0.1

	# Keep sprite on screen
	sprite_desktop_pos.x = clampf(sprite_desktop_pos.x, 10.0, 310.0)
	sprite_desktop_pos.y = clampf(sprite_desktop_pos.y, 10.0, 170.0)
	character_instance.position = sprite_desktop_pos

	# Highlight bin when getting close
	var dist_to_bin = sprite_desktop_pos.distance_to(bin_center)
	if dist_to_bin < 45.0:
		recycle_bin.modulate = Color(1.4, 0.3, 0.3)
	else:
		recycle_bin.modulate = Color(1.0, 1.0, 1.0)

	# Auto-delete if inside bin
	if dist_to_bin < 22.0:
		trigger_deletion()

func trigger_deletion() -> void:
	black_screen.visible = true
	if is_instance_valid(character_instance):
		character_instance.visible = false

func _input(event: InputEvent) -> void:
	if black_screen.visible or not is_instance_valid(character_instance):
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse = get_viewport().get_mouse_position()

		if event.pressed:
			if mouse.distance_to(character_instance.position) < 45.0:
				is_dragging_sprite = true
				last_mouse_pos = mouse
		else:
			if is_dragging_sprite:
				is_dragging_sprite = false
				var bin_center = recycle_bin.position + (recycle_bin.size * 0.5)
				if sprite_desktop_pos.distance_to(bin_center) < 36.0:
					trigger_deletion()
