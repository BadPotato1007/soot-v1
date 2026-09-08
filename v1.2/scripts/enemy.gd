extends CharacterBody2D

@export var move_speed: float = 65.0
@export var weapon: String = "pistol"
@export var ammo: int = 5
@export var bullet_scene: PackedScene = preload("res://scenes/Bullet.tscn")
@export var shatter_scene: PackedScene = preload("res://scenes/ShatterEffect.tscn")
@export var thrown_weapon_scene: PackedScene = preload("res://scenes/ThrownWeapon.tscn")

var shoot_cooldown: float = 1.0
var is_stunned: bool = false
@onready var raycast: RayCast2D = $RayCast2D

func _ready() -> void:
	add_to_group("enemies")

func _physics_process(delta: float) -> void:
	if is_stunned:
		return

	var player = get_tree().get_first_node_in_group("player")
	if not player or not player.visible:
		return

	look_at(player.global_position)
	raycast.target_position = to_local(player.global_position)
	raycast.force_raycast_update()

	var dist = global_position.distance_to(player.global_position)

	if not raycast.is_colliding() or raycast.get_collider() == player:
		if dist > 100.0:
			velocity = transform.x * move_speed
		elif dist < 45.0:
			velocity = -transform.x * move_speed
		else:
			velocity = Vector2.ZERO
		
		shoot_cooldown -= delta
		if shoot_cooldown <= 0.0:
			shoot_cooldown = randf_range(1.1, 1.9)
			fire()
	else:
		velocity = transform.x * (move_speed * 0.4)

	move_and_slide()

func fire() -> void:
	# Screen shakes slightly when shot at
	ScreenShake.shake(2.0, 10.0)
	var b = bullet_scene.instantiate()
	b.global_position = global_position + transform.x * 12
	b.rotation = rotation + randf_range(-0.06, 0.06)
	b.is_player_bullet = false
	get_parent().add_child(b)

func disarm_and_stun() -> void:
	is_stunned = true
	ScreenShake.shake(4.0, 8.0)
	if weapon != "fists":
		var tw = thrown_weapon_scene.instantiate()
		tw.global_position = global_position
		tw.rotation = randf_range(0, TAU)
		tw.throw_direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
		get_parent().add_child(tw)
		weapon = "fists"

	await get_tree().create_timer(1.5).timeout
	is_stunned = false

func shatter() -> void:
	ScreenShake.shake(6.5, 7.0)
	TimeManager.trigger_impact_freeze(0.04)

	var s = shatter_scene.instantiate()
	s.global_position = global_position
	s.shard_color = Color(1.0, 0.08, 0.16)
	get_parent().add_child(s)
	
	# Notify the level manager that this enemy is dead
	var level = get_tree().current_scene
	if level and level.has_method("on_enemy_shattered"):
		level.on_enemy_shattered()
	
	remove_from_group("enemies")
	queue_free() 
