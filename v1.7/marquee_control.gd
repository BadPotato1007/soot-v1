extends Control

@onready var label: Label = $Label
@export var speed: float = 50.0 # Pixels per second downward

var base_text: String = "so\n" 

func _ready() -> void:
	setup_downward_marquee()

func setup_downward_marquee() -> void:
	var font = label.get_theme_font("font")
	var font_size = label.get_theme_font_size("font_size")
	
	# 1. Get the vertical height of a single line of text
	var single_line_height = font.get_height(font_size)
	
	if single_line_height <= 0:
		return

	var screen_height = size.y
	var repeat_count = ceil(screen_height / single_line_height) * 2
	
	label.text = base_text.repeat(repeat_count)
	
	var duration = single_line_height / speed
	var tween = create_tween().set_loops()
	
	# 2. Start the label shifted up by exactly one line width, 
	# and animate it down to position 0.
	tween.tween_property(label, "position:y", 0, duration).from(-single_line_height)
