extends CharacterBody2D

const GRAVITY = 1500.0
const JUMP_VELOCITY = -400.0
const RANDOMIZER = [0.75, 1, 1.25, 1.3, 1.5]

@onready var sprite = $AnimatedSprite2D 

@export var max_health: int = 3
var health: int = 3


func _ready() -> void:
	add_to_group("player")
	health = max_health
	if GameManager.level_loops_left <= 0:
		GameManager.level_loops_left = randi_range(3, 10)


func _physics_process(delta):
	
	if get_tree().paused:
		return
	
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		sprite.play("run")

	# Handle Jump
	if (Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_accept")) and is_on_floor():
		velocity.y = JUMP_VELOCITY * RANDOMIZER.pick_random()
		sprite.play("jump") 

	move_and_slide()

func take_damage(amount: int = 1) -> void:
	get_tree().paused = true
	
	sprite.modulate = Color(2.0, 0.4, 0.4)
	await get_tree().create_timer(0.4, true, false, true).timeout  
	sprite.modulate = Color.WHITE
	
	var damage_overlay = get_tree().get_first_node_in_group("damage_overlay") as CanvasLayer
	if damage_overlay:
		damage_overlay.visible = true
	
	# Increment the count for the next attempt calculation
	GameManager.level_repeats += 1 
	
	# Tell the overlay to spawn the persistent buttons
	if damage_overlay and damage_overlay.has_method("spawn_event_buttons"):
		damage_overlay.spawn_event_buttons()
		
	# Wait for 2 seconds while the user looks at/clicks the useless buttons
	await get_tree().create_timer(2.0, true, false, true).timeout 
	
	# Proceed with level reload/transition
	if GameManager.level_repeats >= GameManager.level_loops_left:
		GameManager.level_repeats = 0
		GameManager.level_loops_left = 0
		get_tree().paused = false
		get_tree().change_scene_to_file("res://scenes/a2to3.tscn")
	else:
		get_tree().paused = false
		get_tree().reload_current_scene()

# Move your reload logic into its own clean function
func proceed_to_next_level() -> void:
	if GameManager.level_repeats >= GameManager.level_loops_left:
		GameManager.level_repeats = 0
		GameManager.level_loops_left = 0
		get_tree().paused = false
		get_tree().change_scene_to_file("res://scenes/a2to3.tscn")
	else:
		get_tree().paused = false
		get_tree().reload_current_scene()

	
