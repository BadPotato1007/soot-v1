extends Node2D

@export_group("3 Separate Scenes")
@export var normal_scene: PackedScene
@export var drift_scene: PackedScene
@export var fall_scene: PackedScene

@export var tumble_speed: float = 2.4

enum State {
	PLATFORM_DRIFT,
	ABYSS_FALL,
	DESKTOP_VIEW,
	BLACK_VOID
}

var current_state: int = State.PLATFORM_DRIFT

# Drift Physics
const DRIFT_SPEED: float = 65.0
const RUN_AGAINST_SPEED: float = 35.0
var player_x: float = 40.0
var player_y: float = 120.0
const PLATFORM_RIGHT_EDGE: float = 230.0

# 15-second Fall phase
var fall_timer: float = 15.0
var stars: Array = []
var pulse_time: float = 0.0

# Character nodes
var node_normal: Node2D = null
var node_drift: Node2D = null
var node_fall: Node2D = null
var active_node: Node2D = null

# UI Layers
@onready var void_text_overlay: CanvasLayer = $VoidTextOverlay
@onready var desktop_layer: CanvasLayer = $DesktopLayer
@onready var desktop_control: Control = $DesktopLayer/Desktop
@onready var recycle_bin: Control = $DesktopLayer/Desktop/RecycleBin

# Desktop Inescapable Drag & Pull State
var is_dragging_sprite: bool = false
var last_mouse_pos: Vector2 = Vector2.ZERO
var sprite_desktop_pos: Vector2 = Vector2(220, 90)

func _ready() -> void:
	Engine.time_scale = 1.0
	desktop_layer.visible = false
	if void_text_overlay:
		void_text_overlay.visible = true

	# 1. Instantiate scenes safely
	if normal_scene:
		node_normal = normal_scene.instantiate()
		setup_node(node_normal)

	if drift_scene:
		node_drift = drift_scene.instantiate()
		setup_node(node_drift)

	if fall_scene:
		node_fall = fall_scene.instantiate()
		setup_node(node_fall)

	# Fallbacks
	if not node_drift and node_normal: node_drift = node_normal
	if not node_fall and node_normal: node_fall = node_normal
	if not node_normal and node_drift: node_normal = node_drift

	if not node_normal:
		node_normal = create_fallback_sprite_node()
		node_drift = node_normal
		node_fall = node_normal

	switch_active_node("drift")

	# Stars
	for i in range(90):
		stars.append({
			"pos": Vector2(randf_range(0, 320), randf_range(0, 180)),
			"speed": randf_range(30.0, 160.0),
			"brightness": randf_range(0.3, 1.0),
			"size": randf_range(1.0, 2.5)
		})

func setup_node(n: Node2D) -> void:
	add_child(n)
	n.z_index = 10
	
	for child in n.get_children():
		if child is ColorRect or child is Panel:
			child.visible = false

	var anim: AnimatedSprite2D = null
	if n is AnimatedSprite2D:
		anim = n
	else:
		anim = n.find_child("*", true, false) as AnimatedSprite2D
	if anim:
		anim.play()

func create_fallback_sprite_node() -> Node2D:
	var root = Node2D.new()
	root.z_index = 10
	var col = ColorRect.new()
	col.offset_left = -6
	col.offset_top = -12
	col.offset_right = 6
	col.offset_bottom = 12
	col.color = Color(0.1, 0.1, 0.12)
	root.add_child(col)
	add_child(root)
	return root

func set_node_flip_h(parent_node: Node2D, flipped: bool) -> void:
	var anim: AnimatedSprite2D = null
	if parent_node is AnimatedSprite2D:
		anim = parent_node
	else:
		anim = parent_node.find_child("*", true, false) as AnimatedSprite2D
	if anim:
		anim.flip_h = flipped

func switch_active_node(mode: String) -> void:
	var target: Node2D = null
	match mode:
		"normal": target = node_normal
		"drift": target = node_drift
		"fall": target = node_fall

	if target == active_node and active_node != null:
		return

	if is_instance_valid(node_normal): node_normal.visible = false
	if is_instance_valid(node_drift): node_drift.visible = false
	if is_instance_valid(node_fall): node_fall.visible = false

	active_node = target
	if is_instance_valid(active_node):
		active_node.visible = true

func _process(delta: float) -> void:
	pulse_time += delta

	match current_state:
		State.PLATFORM_DRIFT:
			process_platform_drift(delta)
		State.ABYSS_FALL:
			process_abyss_fall(delta)
		State.DESKTOP_VIEW:
			process_desktop(delta)

	queue_redraw()

func process_platform_drift(delta: float) -> void:
	var fighting_left = Input.is_action_pressed("move_left")
	var net_speed = (DRIFT_SPEED - RUN_AGAINST_SPEED) if fighting_left else DRIFT_SPEED
	player_x += net_speed * delta

	if fighting_left:
		switch_active_node("normal")
	else:
		switch_active_node("drift")

	if is_instance_valid(active_node):
		active_node.global_position = Vector2(player_x, player_y)
		active_node.rotation = 0.0
		set_node_flip_h(active_node, fighting_left)

	if player_x < 24.0:
		player_x = 24.0

	if player_x >= PLATFORM_RIGHT_EDGE:
		current_state = State.ABYSS_FALL
		player_x = 160.0
		player_y = 90.0
		switch_active_node("fall")

func process_abyss_fall(delta: float) -> void:
	for s in stars:
		s.pos.y -= s.speed * delta
		if s.pos.y < 0:
			s.pos.y = 180.0
			s.pos.x = randf_range(0, 320)

	if is_instance_valid(active_node):
		active_node.global_position = Vector2(160, 90)
		#active_node.rotation += tumble_speed * delta

	fall_timer -= delta
	if fall_timer <= 0.0:
		transition_to_desktop()

func transition_to_desktop() -> void:
	current_state = State.DESKTOP_VIEW
	if void_text_overlay:
		void_text_overlay.visible = false
	desktop_layer.visible = true

	switch_active_node("normal")
	if is_instance_valid(active_node):
		active_node.visible = true
		sprite_desktop_pos = Vector2(220, 90)
		active_node.global_position = sprite_desktop_pos
		active_node.rotation = 0.0
		if active_node.get_parent() != desktop_control:
			active_node.get_parent().remove_child(active_node)
			desktop_control.add_child(active_node)
		active_node.z_index = 100

func process_desktop(delta: float) -> void:
	if not is_instance_valid(active_node):
		return

	var bin_center = recycle_bin.position + (recycle_bin.size * 0.5)

	# 1. Subtle ambient gravitational pull toward the recycle bin at all times
	#var to_bin = (bin_center - sprite_desktop_pos).normalized()
	#sprite_desktop_pos += to_bin * (24.0 * delta)

	# 2. Inescapable Drag Logic when mouse is held down
	if is_dragging_sprite:
		var current_mouse = get_viewport().get_mouse_position()
		var mouse_delta = current_mouse - last_mouse_pos
		last_mouse_pos = current_mouse

		if mouse_delta.length_squared() > 0.01:
			var dir_to_bin = (bin_center - sprite_desktop_pos).normalized()
			var dot = mouse_delta.dot(dir_to_bin)

			if dot >= 0:
				# Moving TOWARD bin: allow normal drag movement
				sprite_desktop_pos += mouse_delta
			else:
				# Trying to move AWAY from bin: REVERSE IT and pull TOWARD the bin instead!
				var move_distance = mouse_delta.length()
				# Moves toward the bin proportional to how hard they try to resist
				sprite_desktop_pos += dir_to_bin * (move_distance * 0.9 + 1.5)

	# Keep within desktop bounds
	sprite_desktop_pos.x = clampf(sprite_desktop_pos.x, 10.0, 310.0)
	sprite_desktop_pos.y = clampf(sprite_desktop_pos.y, 10.0, 170.0)
	active_node.position = sprite_desktop_pos

	# Distance to bin center
	var dist_to_bin = sprite_desktop_pos.distance_to(bin_center)

	# Highlight bin when getting close
	if dist_to_bin < 45.0:
		recycle_bin.modulate = Color(1.4, 0.3, 0.3)
	else:
		recycle_bin.modulate = Color(1.0, 1.0, 1.0)

	# Automatic deletion if sucked into or dragged into the bin
	if dist_to_bin < 22.0:
		trigger_deletion()

func trigger_deletion() -> void:
	current_state = State.BLACK_VOID
	desktop_layer.visible = false
	if is_instance_valid(active_node):
		active_node.visible = false

func _input(event: InputEvent) -> void:
	if current_state != State.DESKTOP_VIEW or not is_instance_valid(active_node):
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse = get_viewport().get_mouse_position()

		if event.pressed:
			# Generous grab radius around character
			if mouse.distance_to(active_node.position) < 45.0:
				is_dragging_sprite = true
				last_mouse_pos = mouse
		else:
			if is_dragging_sprite:
				is_dragging_sprite = false
				var bin_center = recycle_bin.position + (recycle_bin.size * 0.5)
				if sprite_desktop_pos.distance_to(bin_center) < 36.0:
					trigger_deletion()

func _draw() -> void:
	if current_state == State.BLACK_VOID:
		draw_rect(Rect2(0, 0, 320, 180), Color.BLACK)
		return

	# Deep black cosmic space background
	draw_rect(Rect2(0, 0, 320, 180), Color(0.01, 0.01, 0.02))

	if current_state == State.PLATFORM_DRIFT:
		# 1. Minecraft Endstone platform
		var plat_rect = Rect2(0, 130, PLATFORM_RIGHT_EDGE, 50)
		draw_rect(plat_rect, Color(0.88, 0.88, 0.72))
		
		# Endstone crater speckles
		for x in range(0, int(PLATFORM_RIGHT_EDGE), 4):
			for y in range(130, 180, 4):
				var n = sin(float(x) * 12.3 + float(y) * 45.1)
				if n > 0.3:
					draw_rect(Rect2(x, y, 3, 3), Color(0.72, 0.73, 0.58))
				elif n < -0.3:
					draw_rect(Rect2(x, y, 2, 2), Color(0.96, 0.96, 0.85))

		# 2. Golden / Yellow Goal Block
		var glow_alpha = 0.25 + 0.15 * sin(pulse_time * 4.0)
		draw_rect(Rect2(-2, 102, 26, 32), Color(1.0, 0.9, 0.2, glow_alpha))
		draw_rect(Rect2(0, 106, 20, 24), Color(0.98, 0.82, 0.15))
		draw_rect(Rect2(2, 108, 16, 20), Color(1.0, 0.92, 0.35))
		draw_rect(Rect2(0, 106, 20, 24), Color(0.8, 0.65, 0.08), false, 1.0)

	elif current_state == State.ABYSS_FALL:
		for s in stars:
			var c = Color(1, 1, 1, s.brightness)
			draw_circle(s.pos, s.size, c)
