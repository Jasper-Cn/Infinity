extends RichTextLabel

class_name TypewriterLabel

@export var bloop: AudioStreamPlayer
@export var text_to_display : String
@export var timer: Timer
@export_range(.01, .5, .01) var _wait_time : float = .05
var _character_pos : int = 0
var _is_animating : bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.wait_time = _wait_time
	start_animation()

func start_animation() -> void:
	_is_animating = true
	timer.start()
	text = ""
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("click"):
		if _is_animating:
			_is_animating = false
			text = text_to_display
			timer.stop()

func _on_timer_timeout() -> void:
	_character_pos += 1
	text = text_to_display.substr(0, _character_pos)
	if _character_pos == text_to_display.length():
		_is_animating = false
		timer.stop()
		return
	bloop.play()
	timer.start()
