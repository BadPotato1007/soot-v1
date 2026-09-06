extends Node2D

@onready var player = $Soot
# Called when the node enters the scene tree for the first time.
func _ready():
	player.up_direction = Vector2.DOWN

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
