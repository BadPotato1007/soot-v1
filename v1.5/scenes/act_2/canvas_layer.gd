extends CanvasLayer

@onready var template_button: Button = $VBoxContainer/Button2

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("damage_overlay")
	template_button.hide()
	
func spawn_event_buttons() -> void:
	# 1. Determine the current attempt number (starting at 1)
	var current_attempt = GameManager.level_repeats
	if current_attempt <= 0:
		current_attempt = 1
		
	var spawn_count: int = 1
	
	# 2. Scale ranges up with each subsequent attempt
	if current_attempt == 1:
		spawn_count = 1
	elif current_attempt == 2:
		spawn_count = randi_range(2, 5)
	elif current_attempt == 3:
		spawn_count = randi_range(5, 15)
	elif current_attempt == 4:
		spawn_count = randi_range(15, 40)
	else:
		# Multiplies scaling for level 5 and beyond
		var min_range = 40 + ((current_attempt - 5) * 15)
		var max_range = 70 + ((current_attempt - 5) * 25)
		spawn_count = randi_range(min_range, max_range)
		
	# 3. Enforce the hard cap constraint (never lower than 1, never higher than 100)
	spawn_count = clampi(spawn_count, 1, 100)
		
	# 4. Spawn the final calculated amount of buttons
	for i in range(spawn_count):
		spawn_button_randomly()

		
func spawn_button_randomly() -> void:
	var new_button = template_button.duplicate()
	add_child(new_button)
	new_button.show()
	
	new_button.process_mode = Node.PROCESS_MODE_ALWAYS
	# No signal connections here means they do nothing when clicked!
	
	var screen_size = get_viewport().get_visible_rect().size
	var random_x = randf_range(0, screen_size.x - new_button.size.x)
	var random_y = randf_range(0, screen_size.y - new_button.size.y)
	
	new_button.position = Vector2(random_x, random_y)
