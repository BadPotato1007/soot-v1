extends CharacterBody2D

@export var move_speed: float = 140.0
@export var bullet_scene: PackedScene = preload("res://scenes/Bullet.tscn")
@export var thrown_weapon_scene: PackedScene = preload("res://scenes/ThrownWeapon.tscn")
@export var shatter_scene: PackedScene = preload("res://scenes/ShatterEffect.tscn")

var weapon: String = "pistol"
var ammo: int = 8
var max_ammo: int = 8
var attack_cooldown: float = 0.0
var hotswitch_ready: bool = true

signal ammo_updated(current: int, max_val: int)
signal weapon_updated(name: String)

func _ready() -> void:
	add_to_group("player")
	if has_node("Camera2D") and get_node_or_null("/root/ScreenShake") != null:
		ScreenShake.target_camera = $Camera2D
	ammo_updated.emit(ammo, max_ammo)
	weapon_updated.emit(weapon)
	
func _physics_process(delta: float) -> void:
	look_at(get_global_mouse_position())

	var input_vec = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_vec * move_speed
	move_and_slide()

	var is_moving = input_vec.length_squared() > 0.01
	var is_firing = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	TimeManager.player_is_acting = is_moving or is_firing

	if attack_cooldown > 0.0:
		attack_cooldown -= delta

	if Input.is_action_just_pressed("attack") and attack_cooldown <= 0.0:
		fire_weapon()

	if Input.is_action_just_pressed("throw_weapon") and weapon != "fists":
		throw_equipped_weapon()

	if Input.is_action_just_pressed("hotswitch") and hotswitch_ready:
		attempt_hotswitch()

func fire_weapon() -> void:
	if weapon == "fists":
		attack_cooldown = 0.3
		melee_strike()
		return

	if ammo <= 0:
		ScreenShake.shake(1.5, 12.0)
		return

	ammo -= 1
	emit_signal("ammo_updated", ammo, max_ammo)
	attack_cooldown = 0.22

	# Slight recoil screen shake
	ScreenShake.shake(3.0, 10.0)

	var b = bullet_scene.instantiate()
	b.global_position = global_position + transform.x * 12
	b.rotation = rotation
	b.is_player_bullet = true
	get_parent().add_child(b)

func melee_strike() -> void:
	ScreenShake.shake(2.5, 10.0)
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if global_position.distance_to(enemy.global_position) < 32.0:
			enemy.disarm_and_stun()
			break

func throw_equipped_weapon() -> void:
	ScreenShake.shake(2.0, 8.0)
	var tw = thrown_weapon_scene.instantiate()
	tw.global_position = global_position + transform.x * 12
	tw.rotation = rotation
	tw.throw_direction = transform.x
	get_parent().add_child(tw)
	
	weapon = "fists"
	ammo = 0
	emit_signal("weapon_updated", weapon)
	emit_signal("ammo_updated", ammo, max_ammo)

func attempt_hotswitch() -> void:
	var mouse_pos = get_global_mouse_position()
	var enemies = get_tree().get_nodes_in_group("enemies")
	var target_enemy = null
	var min_dist = 50.0

	for enemy in enemies:
		var d = mouse_pos.distance_to(enemy.global_position)
		if d < min_dist:
			min_dist = d
			target_enemy = enemy

	if target_enemy:
		# Shatter old body
		var old_shatter = shatter_scene.instantiate()
		old_shatter.global_position = global_position
		old_shatter.shard_color = Color(0.1, 0.1, 0.1)
		get_parent().add_child(old_shatter)

		# Swapped!
		global_position = target_enemy.global_position
		weapon = target_enemy.weapon
		ammo = target_enemy.ammo
		emit_signal("weapon_updated", weapon)
		emit_signal("ammo_updated", ammo, max_ammo)
		
		target_enemy.shatter()
		TimeManager.trigger_impact_freeze(0.1)
		ScreenShake.shake(8.0, 6.0)

func die() -> void:
	ScreenShake.shake(14.0, 4.0)
	TimeManager.trigger_impact_freeze(0.15)
	var s = shatter_scene.instantiate()
	s.global_position = global_position
	s.shard_color = Color(0.12, 0.12, 0.14)
	get_parent().add_child(s)
	visible = false
	set_physics_process(false)
	
	await get_tree().create_timer(1.0).timeout
	GameManager.restart_current_level()
