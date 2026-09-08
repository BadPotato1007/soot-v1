extends Node2D

@export var enemy_scene: PackedScene = preload("res://scenes/Enemy.tscn")
@export var shatter_scene: PackedScene = preload("res://scenes/ShatterEffect.tscn")
@export var player_node: CharacterBody2D

const AGGRESSIVE_MUSIC_DIR := "res://assets/music/aggressive/mp3"
const AUDIO_EXTENSIONS := ["mp3", "wav"]

var stage_titles: Array = [
	"STAGE 1: THE FOYER",
	"STAGE 2: THE CORRIDOR",
	"STAGE 3: THE ELEVATOR",
	"STAGE 4: OFFICE CUBICLES",
	"STAGE 5: WAREHOUSE CROSSFIRE",
	"STAGE 6: ROOFTOP SNIPERS",
	"STAGE 7: THE PENTHOUSE",
	"STAGE 8: CORE MAINFRAME"
]

var level_cleared: bool = false
var enemies_remaining: int = 0
var red_core_node: StaticBody2D = null

# Tracks the external background media process
var external_audio_pid: int = -1

@onready var walls_container: Node2D = $Walls
@onready var enemies_container: Node2D = $Enemies
@onready var ui: CanvasLayer = $UI

func _ready() -> void:
	TimeManager.set_slow_motion_enabled(true)
	play_external_aggressive_music()
	load_stage(GameManager.current_level_index)

func _exit_tree() -> void:
	stop_external_music()

func play_external_aggressive_music() -> void:
	var song_paths: Array[String] = []
	var dir := DirAccess.open(AGGRESSIVE_MUSIC_DIR)
	
	if dir == null:
		push_error("[BGM] Could not open directory: %s" % AGGRESSIVE_MUSIC_DIR)
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir():
			var clean_name := file_name.trim_suffix(".remap").trim_suffix(".import")
			var ext := clean_name.get_extension().to_lower()
			if AUDIO_EXTENSIONS.has(ext):
				var path := "%s/%s" % [AGGRESSIVE_MUSIC_DIR, clean_name]
				if not song_paths.has(path):
					song_paths.append(path)
		file_name = dir.get_next()
	dir.list_dir_end()
	
	if song_paths.is_empty():
		push_warning("[BGM] No MP3 or WAV tracks found in: %s" % AGGRESSIVE_MUSIC_DIR)
		return

	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var selected_path := song_paths[rng.randi_range(0, song_paths.size() - 1)]

	# Convert res:// to an absolute OS filesystem path
	var absolute_audio_path := ProjectSettings.globalize_path(selected_path)
	if OS.get_name() == "Windows":
		absolute_audio_path = absolute_audio_path.replace("/", "\\")
	
	stop_external_music()

	var os_name := OS.get_name()

	if os_name == "Windows":
		# PowerShell script using PresentationCore MediaPlayer (Native Windows MP3/WAV playback with seamless looping)
		var ps_script := (
			"Add-Type -AssemblyName presentationCore; " +
			"$player = New-Object System.Windows.Media.MediaPlayer; " +
			"$player.Open([System.Uri]'%s'); " +
			"$player.add_MediaEnded({ $player.Position = [System.TimeSpan]::Zero; $player.Play() }); " +
			"$player.Play(); " +
			"while($true){ Start-Sleep -Seconds 1 }"
		) % absolute_audio_path

		external_audio_pid = OS.create_process("powershell.exe", [
			"-WindowStyle", "Hidden",
			"-NoProfile",
			"-ExecutionPolicy", "Bypass",
			"-Command", ps_script
		])
	elif os_name == "macOS":
		external_audio_pid = OS.create_process("afplay", [absolute_audio_path])
	elif os_name == "Linux":
		external_audio_pid = OS.create_process("ffplay", ["-nodisp", "-loop", "0", absolute_audio_path])

	if external_audio_pid <= 0:
		push_error("[BGM] Failed to start external audio process.")

func stop_external_music() -> void:
	if external_audio_pid > 0:
		OS.kill(external_audio_pid)
		external_audio_pid = -1

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("restart"):
		GameManager.restart_current_level()

func on_enemy_shattered() -> void:
	enemies_remaining = max(0, enemies_remaining - 1)
	if ui and ui.has_method("update_enemies"):
		ui.update_enemies(enemies_remaining)

	if enemies_remaining == 0 and not level_cleared:
		if GameManager.current_level_index == 7:
			activate_core_vulnerability()
		else:
			trigger_victory()

func activate_core_vulnerability() -> void:
	level_cleared = true
	ScreenShake.shake(8.0, 5.0)
	TimeManager.trigger_impact_freeze(0.08)
	
	if ui and ui.has_method("set_stage_title"):
		ui.set_stage_title("SHOOT THE CORE")

	if is_instance_valid(red_core_node):
		red_core_node.set_meta("vulnerable", true)
		var tween = create_tween().set_loops()
		var vis = red_core_node.get_node_or_null("CoreVisual")
		if vis:
			tween.tween_property(vis, "color", Color(1.0, 0.4, 0.4), 0.25)
			tween.tween_property(vis, "color", Color(1.0, 0.05, 0.1), 0.25)

func trigger_victory() -> void:
	level_cleared = true
	ScreenShake.shake(18.0, 2.5)
	TimeManager.trigger_impact_freeze(0.12)
	
	if ui and ui.has_method("show_clear_banner"):
		ui.show_clear_banner()

	await get_tree().create_timer(1.8).timeout
	stop_external_music()
	GameManager.next_level()
	get_tree().reload_current_scene()

func clear_stage() -> void:
	enemies_remaining = 0
	for c in enemies_container.get_children():
		c.queue_free()
	for w in walls_container.get_children():
		if not w.is_in_group("boundary"):
			w.queue_free()

func load_stage(idx: int) -> void:
	level_cleared = false
	clear_stage()
	
	if ui and ui.has_method("set_stage_title"):
		ui.set_stage_title(stage_titles[idx])

	match idx:
		0:
			player_node.global_position = Vector2(50, 90)
			spawn_enemy(Vector2(240, 60))
			spawn_enemy(Vector2(240, 120))
			add_pillar(Vector2(160, 90), Vector2(16, 40))
		1:
			player_node.global_position = Vector2(30, 90)
			add_wall(Vector2(160, 55), Vector2(260, 10))
			add_wall(Vector2(160, 125), Vector2(260, 10))
			spawn_enemy(Vector2(170, 90))
			spawn_enemy(Vector2(250, 90))
		2:
			player_node.global_position = Vector2(160, 90)
			add_wall(Vector2(110, 90), Vector2(8, 80))
			add_wall(Vector2(210, 90), Vector2(8, 80))
			spawn_enemy(Vector2(130, 65))
			spawn_enemy(Vector2(190, 65))
			spawn_enemy(Vector2(160, 125))
		3:
			player_node.global_position = Vector2(40, 40)
			add_pillar(Vector2(100, 60), Vector2(12, 40))
			add_pillar(Vector2(160, 120), Vector2(40, 12))
			add_pillar(Vector2(220, 60), Vector2(12, 40))
			spawn_enemy(Vector2(140, 50))
			spawn_enemy(Vector2(100, 130))
			spawn_enemy(Vector2(260, 130))
		4:
			player_node.global_position = Vector2(160, 90)
			add_pillar(Vector2(90, 50), Vector2(20, 20))
			add_pillar(Vector2(230, 50), Vector2(20, 20))
			add_pillar(Vector2(90, 130), Vector2(20, 20))
			add_pillar(Vector2(230, 130), Vector2(20, 20))
			spawn_enemy(Vector2(40, 35))
			spawn_enemy(Vector2(280, 35))
			spawn_enemy(Vector2(40, 145))
			spawn_enemy(Vector2(280, 145))
		5:
			player_node.global_position = Vector2(40, 90)
			add_wall(Vector2(140, 45), Vector2(10, 50))
			add_wall(Vector2(180, 135), Vector2(10, 50))
			spawn_enemy(Vector2(270, 40))
			spawn_enemy(Vector2(270, 90))
			spawn_enemy(Vector2(270, 140))
		6:
			player_node.global_position = Vector2(40, 90)
			add_pillar(Vector2(130, 90), Vector2(24, 24))
			add_pillar(Vector2(190, 90), Vector2(24, 24))
			spawn_enemy(Vector2(160, 40))
			spawn_enemy(Vector2(160, 140))
			spawn_enemy(Vector2(260, 60))
			spawn_enemy(Vector2(260, 120))
		7:
			player_node.global_position = Vector2(160, 145)
			spawn_enemy(Vector2(60, 40))
			spawn_enemy(Vector2(160, 40))
			spawn_enemy(Vector2(260, 40))
			spawn_enemy(Vector2(60, 100))
			spawn_enemy(Vector2(260, 100))
			spawn_red_core(Vector2(160, 90), Vector2(32, 32))

	if ui and ui.has_method("update_enemies"):
		ui.update_enemies(enemies_remaining)

func spawn_enemy(pos: Vector2) -> void:
	var e = enemy_scene.instantiate()
	e.global_position = pos
	enemies_container.add_child(e)
	enemies_remaining += 1

func spawn_red_core(pos: Vector2, sz: Vector2) -> void:
	red_core_node = StaticBody2D.new()
	red_core_node.position = pos
	red_core_node.add_to_group("red_core")
	red_core_node.add_to_group("walls")
	red_core_node.set_meta("vulnerable", false)

	var col = CollisionShape2D.new()
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = sz
	col.shape = rect_shape
	red_core_node.add_child(col)

	var rect_vis = ColorRect.new()
	rect_vis.name = "CoreVisual"
	rect_vis.color = Color(0.95, 0.08, 0.16)
	rect_vis.offset_left = -sz.x / 2.0
	rect_vis.offset_top = -sz.y / 2.0
	rect_vis.offset_right = sz.x / 2.0
	rect_vis.offset_bottom = sz.y / 2.0
	red_core_node.add_child(rect_vis)

	walls_container.add_child(red_core_node)

func destroy_core_and_transition() -> void:
	if not is_instance_valid(red_core_node):
		return

	ScreenShake.shake(25.0, 2.0)
	TimeManager.trigger_impact_freeze(0.2)
	
	var s = shatter_scene.instantiate()
	s.global_position = red_core_node.global_position
	s.shard_color = Color(1.0, 0.08, 0.16)
	get_parent().add_child(s)
	
	red_core_node.queue_free()
	red_core_node = null
	Engine.time_scale = 1.0

	await get_tree().create_timer(1.0).timeout
	stop_external_music()
	get_tree().change_scene_to_file("res://scenes/VoidEnding.tscn")

func add_pillar(pos: Vector2, sz: Vector2) -> void:
	var sb = StaticBody2D.new()
	sb.position = pos
	sb.add_to_group("walls")
	
	var col = CollisionShape2D.new()
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = sz
	col.shape = rect_shape
	sb.add_child(col)

	var rect_vis = ColorRect.new()
	rect_vis.color = Color(0.12, 0.12, 0.14)
	rect_vis.offset_left = -sz.x / 2.0
	rect_vis.offset_top = -sz.y / 2.0
	rect_vis.offset_right = sz.x / 2.0
	rect_vis.offset_bottom = sz.y / 2.0
	sb.add_child(rect_vis)

	walls_container.add_child(sb)

func add_wall(pos: Vector2, sz: Vector2) -> void:
	add_pillar(pos, sz)
