extends Node2D
class_name Subject

const BLOCK_SIZE: float = 80

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
@export var color_rect_5: ColorRect

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
var moused: String = ""
var default_color: Color

func _ready() -> void:
	default_color = color
	label.text = str(self_number)
	coord_arr = [coord_1, coord_2, coord_3, coord_4]
	rect_arr = [color_rect_1, color_rect_2, color_rect_3, color_rect_4]
	EventBus.get_subject_info.connect(_subject_info_dump)
	EventBus.set_subject_info.connect(_subject_info_grab)
	EventBus.update_subject_color.connect(_set_color)
	EventBus.drag.connect(_stop_dragging)
	EventBus.subject_something_update.connect(subject_change_property)
	_set_position()


func _process(delta: float) -> void:
	if Global.current_popup_page == "":
		if visible:
			if Global.mouse_dragging_item == self_number:
				_set_color()
				z_index += 1
				get_parent().move_child(self, 0)
				if Global.mouse_over_ui_panel:
					if Global.control_type == 1:
						_control_type_1_subject_movement(delta)
					elif Global.animations_type[3] == 2:
						global_position = get_global_mouse_position()
						global_position = global_position.snapped(Global.TILE_SIZE)
					else:
						ideal_global_position = ideal_global_position.move_toward(get_global_mouse_position(), 80)
						_tween_position_property()
				if Global.control_type == 2:
					moused = "-Mouse"
				else:
					moused = ""
				if Input.is_action_just_pressed("Rotate" + moused):
					_rotate()
				if Input.is_action_just_pressed("Flip" + moused):
					_flip()
			else:
				z_index = 0
				get_parent().move_child(self, self_number)
			if Input.is_action_just_pressed("click") and is_touching_mouse:
				if not is_dragging and not Global.mouse_dragging_item == -1:
					EventBus.drag.emit(Global.mouse_dragging_item)
				_dragging()
		
		if Input.is_action_just_pressed("set camera") and Global.control_type == 1:
			if Global.mouse_dragging_item == self_number:
				_dragging()
			elif Global.previous_mdi == self_number and Global.mouse_dragging_item == -1:
				_dragging()
		
		if Input.is_action_just_pressed(str(self_number)) and not Global.control_type == 2:
			if not is_dragging and not Global.mouse_dragging_item == -1:
				EventBus.drag.emit(Global.mouse_dragging_item)
			_dragging()
		
		if Input.is_action_just_pressed("Transparency"):
			color.a = 1.8 - color.a
			_set_color()


func _control_type_1_subject_movement(delta: float) -> void:
	if Input.is_action_just_pressed("Left"):
		ideal_global_position.x -= Global.TILE_SIZE.x
	if Input.is_action_just_pressed("Right"):
		ideal_global_position.x += Global.TILE_SIZE.x
	if Input.is_action_just_pressed("Up"):
		ideal_global_position.y -= Global.TILE_SIZE.y
	if Input.is_action_just_pressed("Down"):
		ideal_global_position.y += Global.TILE_SIZE.y
	var input_dir := Input.get_vector("Left", "Right", "Up", "Down")
	if input_dir != Vector2.ZERO:
		timer += delta
		if timer >= wait_time:
			ideal_global_position += ceil(input_dir) * Global.TILE_SIZE
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
			tweener.tween_property(self, "global_position", _calculate_ideal_global_position(), duration)


func _position_tween_to_grid() -> void:
	Global.previous_mdi = Global.mouse_dragging_item
	Global.mouse_dragging_item = -1
	ideal_global_position = _calculate_ideal_global_position()
	_tween_position_property()


func _calculate_ideal_global_position() -> Vector2:
	return Vector2(floor((ideal_global_position + (Global.TILE_SIZE/2))/Global.TILE_SIZE)*Global.TILE_SIZE)


func _set_color(rect_0_minus_color: float = 0.2, rect_other: float = 0) -> void:
	color_rect_0.color = Color(color.r - rect_0_minus_color, color.g - rect_0_minus_color, color.b - rect_0_minus_color, color.a)
	for i in rect_arr.size():
		rect_arr[i].color = Color(color.r - rect_other, color.g - rect_other, color.b - rect_other, color.a)


func _set_position() -> void:
	for i in rect_arr.size():
		if coord_arr[i] == Vector2i(0, 0):
			rect_arr[i].hide()
		else:
			rect_arr[i].position.x = coord_arr[i].x * Global.TILE_SIZE.x - BLOCK_SIZE/2
			rect_arr[i].position.y = coord_arr[i].y * Global.TILE_SIZE.y - BLOCK_SIZE/2
	_set_color()


func _rotate() -> void:
	ideal_rotation_degrees += ideal_scale_x * int(Global.ROTATION_DEGREES_AMOUNT)
	ideal_block_rotation_degrees -= ideal_scale_x * int(Global.ROTATION_DEGREES_AMOUNT)
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


func _stop_dragging(selected_num: int) -> void:
	if selected_num == self_number:
		is_dragging = not is_dragging
		_position_tween_to_grid()
		_color_rect_tweening("scale", Vector2(1, 1), 0.1)


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
		Global.subject_info = [position, ideal_rotation_degrees, ideal_scale_x]


func _subject_info_grab(subject_num: int) -> void:
	if subject_num == self_number:
		position = Global.subject_info[0]
		ideal_rotation_degrees = Global.subject_info[1]
		ideal_scale_x = Global.subject_info[2]
		rotation_2d.rotation_degrees = ideal_rotation_degrees
		flip_2d.scale.x = ideal_scale_x


func subject_change_property(type: String) -> void:
	if type == "Transparent":
		color.a = 1.8 - color.a
		_set_color()
	elif Global.current_popup_page == "" and visible and Global.mouse_dragging_item == self_number:
		match type:
			"Rotate":
				_rotate()
			"Flip":
				_flip()
	elif Global.current_popup_page == "" and Global.mouse_dragging_item == -1:
		match type:
			"Rotate":
				_rotate()
			"Flip":
				_flip()
