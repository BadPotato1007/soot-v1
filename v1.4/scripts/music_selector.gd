extends Node

const MUSIC_ROOT := "res://assets/music"
const AUDIO_EXTENSIONS := ["ogg", "wav", "mp3"]

enum Section {
	NORMAL,
	SUPERHOT,
	ENDING,
}

@export_category("Playback")
@export var ending_song_path: String = ""
@export var autoplay: bool = false

var audio_player: AudioStreamPlayer
var _random := RandomNumberGenerator.new()

func _ready() -> void:
	_random.randomize()
	audio_player = AudioStreamPlayer.new()
	audio_player.name = "MusicPlayer"
	add_child(audio_player)

	if autoplay:
		play_for(1, 1)

func play_for(act: int, level: int, section: Section = Section.NORMAL) -> void:
	var song := pick_song(act, level, section)
	if song == null:
		return
	audio_player.stream = song
	audio_player.play()

func pick_song(act: int, level: int, section: Section = Section.NORMAL) -> AudioStream:
	if section == Section.ENDING:
		return _load_fixed_ending_song()

	var category := _category_for(act, level, section)
	if category == "":
		push_error("No music category is configured for act %d, level %d." % [act, level])
		return null

	var song_paths := _song_paths(category)
	if song_paths.is_empty():
		push_error("No audio files found in %s." % _music_directory(category))
		return null

	# 1. Filter out songs that have already been played
	var available_songs: Array[String] = []
	for path in song_paths:
		if not MusicHistory.played_songs.has(path):
			available_songs.append(path)

	# 2. If ALL songs in this category have been played, reset the history for this category
	if available_songs.is_empty():
		for path in song_paths:
			MusicHistory.played_songs.erase(path)
		available_songs = song_paths # Refill the pool

	# 3. Pick a random song from the available pool
	var selected_path: String = available_songs[_random.randi_range(0, available_songs.size() - 1)]
	
	# 4. Log this song into the global history so it won't play next time
	MusicHistory.played_songs.append(selected_path)

	var song := ResourceLoader.load(selected_path) as AudioStream
	if song == null:
		push_error("Unable to load music file: %s" % selected_path)
	return song


func stop() -> void:
	if audio_player:
		audio_player.stop()

func _category_for(act: int, level: int, section: Section) -> String:
	if section == Section.SUPERHOT:
		return ["aggressive", "scary"][_random.randi_range(0, 1)]

	if act == 1:
		match level:
			1, 2, 4:
				return "happy"
			3:
				return "aggressive"
			5:
				return "scary"
	elif act == 2:
		match level:
			1:
				return "level_1_act_2"
			2:
				return "level_2_act_2"

	return ""

func _load_fixed_ending_song() -> AudioStream:
	if ending_song_path.is_empty():
		push_error("ending_song_path must be set before choosing an ending song.")
		return null
	if not ResourceLoader.exists(ending_song_path):
		push_error("Ending music file does not exist: %s" % ending_song_path)
		return null

	var song := ResourceLoader.load(ending_song_path) as AudioStream
	if song == null:
		push_error("Unable to load ending music file: %s" % ending_song_path)
	return song

func _song_paths(category: String) -> Array[String]:
	var dir_path := _music_directory(category)
	var directory := DirAccess.open(dir_path)
	if directory == null:
		print("CRITICAL: Cannot open directory: ", dir_path)
		return []

	var paths: Array[String] = []
	for file_name in directory.get_files():
		print("Found file in editor: ", file_name) # <-- ADD THIS TEMPORARILY
		var extension := file_name.get_extension().to_lower()
		if AUDIO_EXTENSIONS.has(extension):
			paths.append("%s/%s" % [dir_path, file_name])
	paths.sort()
	return paths


func _music_directory(category: String) -> String:
	return "%s/%s" % [MUSIC_ROOT, category]
