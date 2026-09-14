extends Camera2D

const CAMERA_MOVE_SPEED = 1000

var shake_strength: float = 0
var shake_time: float = 0
var shake_time_left: float = 0


func _process(delta: float) -> void:
	_move_camera(delta)


func _move_camera(delta: float) -> void:
	var input_dir := Input.get_vector("Left", "Right", "Up", "Down")
	if input_dir != Vector2.ZERO:
		position.x += input_dir.x * CAMERA_MOVE_SPEED * delta / (zoom.x/1.2)
		position.y += input_dir.y * CAMERA_MOVE_SPEED * delta / (zoom.y/1.2)
	if Global.current_popup_page == "":
		if Input.is_action_just_pressed("set camera"):
			position = Vector2(0, -45)
			zoom = Vector2(2, 2)
		if Input.is_action_just_pressed("zoom in"):
			if zoom < Vector2(3.9, 3.9):
				zoom += Vector2(0.05, 0.05)
		if Input.is_action_just_pressed("zoom out"):
			if zoom > Vector2(0.11, 0.11):
				zoom -= Vector2(0.05, 0.05)
