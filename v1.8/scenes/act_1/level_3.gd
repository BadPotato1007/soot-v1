extends Node2D

@onready var player = $Soot
@onready var music_selector: Node = $MusicSelector
# Called when the node enters the scene tree for the first time.
func _ready():
	music_selector.play_for(1, 5, music_selector.Section.NORMAL)
