extends Node

# Tuning variables - play with these to get the right feel!
@export var hit_boost: float = 0.15   # How much intensity is added per key press
@export var decay_rate: float = 0.3   # How fast the intensity drops per second

# 0.0 is completely Calm, 1.0 is full Heavy Metal
var intensity: float = 0.0

@onready var audio_player = $AudioStreamPlayer

func _ready():
	# Start all tracks playing together instantly
	audio_player.play()

func _input(event):
	# React to physical key presses (ignores holding down a key)
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		intensity += hit_boost
		intensity = clamp(intensity, 0.0, 1.0)

func _process(delta):
	# Gradually cool down the intensity over time
	if intensity > 0.0:
		intensity -= decay_rate * delta
		intensity = clamp(intensity, 0.0, 1.0)
		
	update_audio()

func update_audio():
	# Get our Synchronized stream from the player
	var sync_stream = audio_player.stream as AudioStreamSynchronized
	if sync_stream:
		# STREAM 0: Jungle Drums (Linear volume of 1.0 means 100% / 0dB)
		sync_stream.set_sync_stream_volume(0, linear_to_db(1.0))
		
		# STREAM 1: Calm Music (Loud when intensity is 0, quiet when intensity is 1)
		var calm_vol = 1.0 - intensity
		sync_stream.set_sync_stream_volume(1, linear_to_db(calm_vol))
		
		# STREAM 2: Heavy Metal (Quiet when intensity is 0, loud when intensity is 1)
		var metal_vol = intensity
		sync_stream.set_sync_stream_volume(2, linear_to_db(metal_vol))
