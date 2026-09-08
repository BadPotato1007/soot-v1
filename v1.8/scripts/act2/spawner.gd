extends Node2D

@export var obstacle_scene: PackedScene = preload("res://Scenes/act_2/obstacle.tscn")

@export var base_min_time: float = 0.9
@export var base_max_time: float = 1.5

@export var absolute_min_time: float = 0.3
@export var base_obstacle_speed: float = 300.0
@export var speed_increase_per_sec: float = 7.5

@export var difficulty_scale_rate: float = 0.04
@export var cluster_spacing: float = 65.0

var elapsed_time: float = 0.0
@onready var timer: Timer = $Timer


func _ready() -> void:
	# Ensure the timer exists and connect its timeout signal
	reset_timer()

func _process(delta: float) -> void:
	# Track total survival time to scale game difficulty
	elapsed_time += delta

func _on_timer_timeout():
	spawn_obstacles()
	reset_timer()

func spawn_obstacles() -> void:
	if not obstacle_scene:
		return

	# Calculate current movement speed for this spawn batch
	var current_speed: float = base_obstacle_speed + (elapsed_time * speed_increase_per_sec)

	# Determine max cluster size based on elapsed time
	var max_cluster: int = 1
	if elapsed_time > 50.0:
		max_cluster = 3
	elif elapsed_time > 20.0:
		max_cluster = 2

	var spawn_count: int = randi_range(1, max_cluster)

	# Instantiate and place each obstacle in the cluster
	for i in range(spawn_count):
		var obstacle = obstacle_scene.instantiate()

		# Offset position horizontally so clustered obstacles don't overlap
		var offset_x: float = i * cluster_spacing
		obstacle.global_position = Vector2(global_position.x + offset_x, global_position.y)

		# Pass current movement speed to obstacle if it has a speed property
		if "speed" in obstacle:
			obstacle.speed = current_speed

		get_parent().add_child(obstacle)


func reset_timer() -> void:
	# Difficulty multiplier (starts at 1.0, increases continuously)
	var difficulty_factor: float = 1.0 + (elapsed_time * difficulty_scale_rate)

	# Calculate current wait bounds based on difficulty
	var current_min: float = max(base_min_time / difficulty_factor, absolute_min_time)
	var current_max: float = max(base_max_time / difficulty_factor, absolute_min_time + 0.4)

	timer.wait_time = randf_range(current_min, current_max)
	timer.start()
