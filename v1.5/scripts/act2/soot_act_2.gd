extends CharacterBody2D

const GRAVITY = 1500.0
const JUMP_VELOCITY = -400.0

@onready var sprite = $AnimatedSprite2D

@export var max_health: int = 3
var health: int = 3

func _ready() -> void:
	TimeManager.set_slow_motion_enabled(false)
	add_to_group("player")
	health = max_health


func _physics_process(delta):
	
	if get_tree().paused:
		return
	
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		sprite.play("run")

	# Handle Jump
	if (Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_accept")) and is_on_floor():
		velocity.y = JUMP_VELOCITY
		sprite.play("jump") 

	move_and_slide()

	# Check for solid collisions with moving obstacles right after moving
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		# Check if the solid object we hit is in the "obstacle" group
		if collider and collider.is_in_group("obstacle"):
			take_damage(1)
			break # Exit the loop so we don't trigger damage multiple times in one frame

func take_damage(amount: int = 1) -> void:
	get_tree().paused = true
	
	sprite.modulate = Color(2.0,0.4,0.4)

	var is_game_over: bool = GameManager.lose_health(amount)

	# 4. Trigger screen shake
	var camera = get_viewport().get_camera_2d()
	if camera:
		shake_camera(camera)
		
	var damage_overlay = get_tree().get_first_node_in_group("damage_overlay") as ColorRect
	if damage_overlay:
		damage_overlay.visible = true
	await get_tree().create_timer(0.4, true, false, true).timeout  
	sprite.modulate = Color.WHITE
	
	if not is_game_over:
		create_hit_menu()


func shake_camera(camera: Camera2D) -> void:
	var original_offset = camera.offset
	var tween = create_tween().set_loops(6) # 6 quick shakes
	
	# Randomize offset during pause
	tween.tween_callback(func
	(): camera.offset = original_offset + Vector2(randf_range(-8, 8), randf_range(-8, 8)))
	tween.tween_interval(0.05)
	
	tween.finished.connect(func(): camera.offset = original_offset)

func create_hit_menu() -> void:
	var canvas = CanvasLayer.new()
	canvas.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Background
	var bg = ColorRect.new()
	bg.color = Color(0.15, 0.15, 0.15, 0.7)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(bg)
	
	# Menu container
	var vbox = VBoxContainer.new()
	vbox.position = Vector2(115, 60)
	vbox.size = Vector2(90, 60)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 4)
	canvas.add_child(vbox)
	
	# Try Again button
	var retry_btn = Button.new()
	retry_btn.text = "Try Again?"
	retry_btn.custom_minimum_size = Vector2(90, 24)
	
	retry_btn.pressed.connect(func():
		sprite.modulate = Color.WHITE
		canvas.queue_free()
		get_tree().paused = false
		get_tree().reload_current_scene()
	)
	
	vbox.add_child(retry_btn)
	
	# Quit button
	var quit_btn = Button.new()
	quit_btn.text = "Quit (DO NOT)"
	quit_btn.custom_minimum_size = Vector2(90, 24)
	
	quit_btn.pressed.connect(func():
		canvas.queue_free()
		get_tree().paused = false
		get_tree().change_scene_to_file("res://scenes/VoidEnding.tscn")
	)
	
	vbox.add_child(quit_btn)
	
	# Add menu to root
	get_tree().root.add_child(canvas)
