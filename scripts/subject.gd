extends Node2D
class_name Subject

@export var color: Color = Color("WHITE")
@export var self_number: int
@export var coord_1: Vector2i
@export var coord_2: Vector2i
@export var coord_3: Vector2i
@export var coord_4: Vector2i

@export var color_rect_0: ColorRect
@export var color_rect_1: ColorRect
@export var color_rect_2: ColorRect
@export var color_rect_3: ColorRect
@export var color_rect_4: ColorRect

@export var rotation_2d: Node2D
@export var flip_2d: Node2D
@export var label: Label

var is_dragging: bool = false
var is_touching_mouse: bool = false
var coord_arr: Array
var rect_arr: Array
var ideal_global_position: Vector2
var ideal_rotation_degrees: int = 0
var ideal_block_rotation_degrees: int = 0
var ideal_scale_x: int = 1
var wait_time: float = 0.3
var timer: float = 0


func _ready() -> void:
	label.text = str(self_number)
	coord_arr = [coord_1, coord_2, coord_3, coord_4]
	rect_arr = [color_rect_1, color_rect_2, color_rect_3, color_rect_4]
	EventBus.update_subject_color.connect(_set_color)
	EventBus.drag.connect(_stop_dragging)
	EventBus.get_subject_info.connect(_subject_info_dump)
	_set_color()


func _process(delta: float) -> void:
	if Global.current_popup_page == "":
		if visible:
			if Global.mouse_dragging_item == self_number:
				_set_color()
				z_index += 1
				if Global.control_type == 1:
					_control_type_1_subject_movement(delta)
				elif Global.animations_type[3] == 2:
					global_position = get_global_mouse_position()
					global_position = global_position.snapped(Global.TILE_SIZE)
				else:
					ideal_global_position = ideal_global_position.move_toward(get_global_mouse_position(), 80)
					_tween_position_property()
				if not Global.control_type == 2:
					if Input.is_action_just_pressed("Rotate"):
						_rotate()
					if Input.is_action_just_pressed("Flip"):
						_flip()
				else:
					if Input.is_action_just_pressed("Rotate-Mouse"):
						_rotate()
					if Input.is_action_just_pressed("Flip-Mouse"):
						_flip()
			else:
				z_index = 0
			if Input.is_action_just_pressed("click") and is_touching_mouse:
				if not is_dragging and not Global.mouse_dragging_item == -1:
					EventBus.drag.emit(Global.mouse_dragging_item)
				_dragging()
		if Input.is_action_just_pressed("set camera"):
			if Global.control_type == 1:
				if Global.mouse_dragging_item == self_number:
					_dragging()
				elif Global.previous_mdi == self_number and Global.mouse_dragging_item == -1:
					_dragging()
		if Input.is_action_just_pressed(str(self_number)):
			if not Global.control_type == 2:
				if not is_dragging and not Global.mouse_dragging_item == -1:
					EventBus.drag.emit(Global.mouse_dragging_item)
				_dragging()
					
		if Input.is_action_just_pressed("Transparency"):
			color.a = 1.8 - color.a
			_set_color()


func _control_type_1_subject_movement(delta: float) -> void:
	if Input.is_action_just_pressed("Left"):
		ideal_global_position.x -= 90
	if Input.is_action_just_pressed("Right"):
		ideal_global_position.x += 90
	if Input.is_action_just_pressed("Up"):
		ideal_global_position.y -= 90
	if Input.is_action_just_pressed("Down"):
		ideal_global_position.y += 90
	var input_dir := Input.get_vector("Left", "Right", "Up", "Down")
	if input_dir != Vector2.ZERO:
		timer += delta
		if timer >= wait_time:
			ideal_global_position += ceil(input_dir) * 90
			wait_time = 0.05
			timer = 0
		_tween_position_property()
	else:
		timer = 0
		wait_time = 0.3


func _tween_position_property(duration: float = 0.1) -> void:
	var tweener : Tween = get_tree().create_tween()
	match Global.animations_type[3]:
		0:
			tweener.tween_property(self, "global_position", Vector2(ideal_global_position.x, ideal_global_position.y), duration)
		1:
			tweener.tween_property(self, "global_position", Vector2(floor((ideal_global_position.x+45)/90)*90, floor((ideal_global_position.y+45)/90)*90), duration)


func _set_color(rect_0: float = 0.2, rect_other: float = 0) -> void:
	color_rect_0.color = Color(color.r - rect_0, color.g - rect_0, color.b - rect_0)
	for i in rect_arr.size():
		if coord_arr[i] == Vector2i(0, 0):
			rect_arr[i].hide()
		else:
			rect_arr[i].position.x = coord_arr[i].x * 90 - 40
			rect_arr[i].position.y = coord_arr[i].y * 90 - 40
		rect_arr[i].color = Color(color.r - rect_other, color.g - rect_other, color.b - rect_other)


func _rotate() -> void:
	ideal_rotation_degrees += ideal_scale_x * 90
	ideal_block_rotation_degrees -= ideal_scale_x * 90
	if Global.animations_type[0] < 2:
		var tweener : Tween = get_tree().create_tween()
		tweener.tween_property(rotation_2d, "rotation_degrees", ideal_rotation_degrees, 0.3)
		if Global.animations_type[0] == 0:
			_color_rect_tweening("rotation_degrees", ideal_block_rotation_degrees, 0.3)
	else:
		rotation_2d.rotation_degrees = ideal_rotation_degrees


func _flip() -> void:
	ideal_scale_x *= -1
	match Global.animations_type[1]:
		0:
			var tweener : Tween = get_tree().create_tween()
			tweener.tween_property(flip_2d, "scale", Vector2(float(0), 0), 0.15)
			tweener.tween_property(flip_2d, "scale", Vector2(float(ideal_scale_x), 1), 0.15)
		1:
			var tweener : Tween = get_tree().create_tween()
			tweener.tween_property(flip_2d, "scale", Vector2(float(ideal_scale_x), 1), 0.3)
		_:
			flip_2d.scale.x = ideal_scale_x
	rotation_2d.rotation_degrees = ideal_rotation_degrees
	_color_rect_tweening("rotation_degrees", ideal_block_rotation_degrees, 0)


func _stop_dragging(selected_num: int) -> void:
	if selected_num == self_number:
		is_dragging = not is_dragging
		_position_tween_to_grid()
		_color_rect_tweening("scale", Vector2(1, 1), 0.1)


func _position_tween_to_grid() -> void:
	Global.previous_mdi = Global.mouse_dragging_item
	Global.mouse_dragging_item = -1
	ideal_global_position.x = floor((ideal_global_position.x+45)/90)*90
	ideal_global_position.y = floor((ideal_global_position.y+45)/90)*90
	_tween_position_property()


func _dragging() -> void:
	is_dragging = not is_dragging
	ideal_global_position = global_position
	if Global.mouse_dragging_item == self_number:
		_position_tween_to_grid()
	else:
		Global.mouse_dragging_item = self_number
	var mult : float = 0
	if is_dragging:
		match Global.animations_type[2]:
			0:
				mult = 1.05
			1:
				mult = 0.9
			_:
				mult = 1
	else:
		mult = 1
	_color_rect_tweening("scale", Vector2(mult, mult), 0.1)


func _color_rect_tweening(type: String, final_val: Variant, duration: float) -> void:
	var rect_tween0 : Tween = get_tree().create_tween()
	rect_tween0.tween_property(color_rect_0, type, final_val, duration)
	for i in rect_arr.size():
		var rect_tween : Tween = get_tree().create_tween()
		rect_tween.tween_property(rect_arr[i], type, final_val, duration)


func _on_color_rect_5_mouse(in_area: bool) -> void:
	if not Global.control_type == 1:
		if not is_dragging:
			if in_area:
				_set_color(0.3, 0.1)
			else:
				_set_color()
		is_touching_mouse = in_area


func _subject_info_dump(subject_num: int) -> void:
	if subject_num == self_number:
		Global.subject_info = [int(position.x), int(position.y), ideal_rotation_degrees, ideal_scale_x]
