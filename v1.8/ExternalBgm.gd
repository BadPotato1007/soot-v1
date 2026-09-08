extends Node

const AGGRESSIVE_MUSIC_DIR := "res://assets/music/aggressive/mp3"
const AUDIO_EXTENSIONS := ["mp3", "wav"]

var external_audio_pid: int = -1
var is_act3_playing: bool = false

func start_act3_music() -> void:
	# If already playing, do not interrupt or restart the track
	if is_act3_playing and external_audio_pid > 0:
		return

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

	var absolute_audio_path := ProjectSettings.globalize_path(selected_path)
	if OS.get_name() == "Windows":
		absolute_audio_path = absolute_audio_path.replace("/", "\\")

	stop_music()

	var os_name := OS.get_name()
	if os_name == "Windows":
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

	if external_audio_pid > 0:
		is_act3_playing = true

func stop_music() -> void:
	if external_audio_pid > 0:
		OS.kill(external_audio_pid)
		external_audio_pid = -1
	is_act3_playing = false

func _notification(what: int) -> void:
	# Make sure the external process is killed if the player closes the game
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_PREDELETE:
		stop_music()
