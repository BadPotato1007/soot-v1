extends Node2D

@onready var music_selector: Node = $MusicSelector
# Called when the node enters the scene tree for the first time.
func _ready():
	music_selector.play_for(2, 2, music_selector.Section.NORMAL)
