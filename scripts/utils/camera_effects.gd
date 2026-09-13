extends Camera2D

var shake_strength: float = 0
var shake_time: float = 0
var shake_time_left: float = 0
const CAMERA_MOVE_SPEED = 1000

func _process(delta: float) -> void:
	#_update_shake(delta)
	_move_camera(delta)


func _move_camera(delta: float) -> void:
	var input_dir := Input.get_vector("Left", "Right", "Up", "Down")
	if input_dir != Vector2.ZERO:
		position.x += input_dir.x * CAMERA_MOVE_SPEED * delta / (zoom.x/1.2)
		position.y += input_dir.y * CAMERA_MOVE_SPEED * delta / (zoom.y/1.2)
	if Input.is_action_just_pressed("set camera"):
		position = Vector2(0, -45)
		zoom = Vector2(2.2, 2.2)


func _unhandled_input(event: InputEvent) -> void:
	if Global.current_popup_page == "":
		if zoom < Vector2(3.9, 3.9):
			if event.as_text() == "Mouse Wheel Up":
				zoom += Vector2(0.05, 0.05)
		if zoom > Vector2(0.11, 0.11):
			if event.as_text() == "Mouse Wheel Down":
				zoom -= Vector2(0.05, 0.05)
		#print(zoom)


## First parameter is snake_strength and determines how many pixels offset
## Second parameter is shake_timer - how long screenShake lasts
## The more powerful time or strength will take precedence
func shake(amount: float = 10.0, duration: float = 0.3) -> void:
	print("Shaking camera with amount:", amount, " duration:", duration)
	
	# makes sure if 2 screenshakes are called, it replaces smaller one with bigger one 
	shake_strength = max(amount, shake_strength)
	shake_time = max(duration, shake_time)
	shake_time_left = max(duration, shake_time_left)

func _update_shake(_delta: float) -> void:
	if shake_time_left > 0 and shake_time > 0:
		# snake_strength and shake_time are used reference and then shake_time_left is the actual time counter updated
		# So it makes the shake fade out
		shake_time_left -= _delta
		var progress_percent : float = shake_time_left / shake_time
		var current_strength : float = progress_percent * shake_strength
		offset = Vector2(randf_range(-current_strength,current_strength),randf_range(-current_strength,current_strength))
	else:
		offset = Vector2(0,0)
		shake_strength = 0
		shake_time = 0
