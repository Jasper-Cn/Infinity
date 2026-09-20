extends Node2D
class_name Subject

const BLOCK_SIZE: float = 80

@export var color: Color = Color("WHITE")
@export var self_number: int
@export var coord_arr: Array[Vector2i]
@export var color_rect_0: ColorRect
@export var color_rect_arr: Array[ColorRect]
#rotation2d, flip2d, number_label
@export var node_arr: Array[Node]

#["global_position", "subject.rotation_degrees", "block.rotation_degrees", "scale.x"]
var ideal_arr: Array = [Vector2(0, 0), 0, 0, 1]
var is_dragging: bool = false
var is_touching_mouse: bool = false
var key_repeat_wait_time: float = 0.3
var key_repeat_timer: float = 0
var default_color: Color


func _ready() -> void:
	default_color = color
	node_arr[2].text = str(self_number)
	connect_EventBus()
	_set_position()


func _process(delta: float) -> void:
	if Global.current_popup_page == "":
		if Global.mouse_dragging_item == self_number:
			
			if Global.mouse_not_over_ui_panel:
				if Global.control_type == 1:
					_control_type_1_subject_movement(delta)
				else:
					if Global.animations_type[3] == 2:
						ideal_arr[0] = get_global_mouse_position()
					else:
						ideal_arr[0] = ideal_arr[0].move_toward(get_global_mouse_position(), Global.TILE_SIZE.x)
					_tween_position_property()
		if Global.mouse_dragging_item == self_number or Global.mouse_dragging_item == -1:
			if Input.is_action_just_pressed("Rotate" + Global.moused):
				_rotate()
			if Input.is_action_just_pressed("Flip" + Global.moused):
				_flip()
			if Input.is_action_just_pressed("Transparency") and not Global.control_type == 2:
				_transparent()
		
		if Input.is_action_just_pressed("click") and is_touching_mouse:
			if not is_dragging and not Global.mouse_dragging_item == -1:
				EventBus.drag.emit(Global.mouse_dragging_item)
			_dragging()
		
		if Input.is_action_just_pressed("space") and Global.control_type == 1:
			if Global.mouse_dragging_item == self_number or\
			(Global.previous_mdi == self_number and Global.mouse_dragging_item == -1):
				_dragging()
		
		if Input.is_action_just_pressed(str(self_number)) and not Global.control_type == 2:
			if not is_dragging and not Global.mouse_dragging_item == -1:
				EventBus.drag.emit(Global.mouse_dragging_item)
			_dragging()

#ready functions, only used once
func connect_EventBus() -> void:
	#subject: telling the other subject to stop dragging
	EventBus.drag.connect(_stop_dragging)
	#settings: copy pasting thingy
	EventBus.get_subject_info.connect(subject_info_dump)
	EventBus.set_subject_info.connect(subject_info_grab)
	#ui: rotate, flip, and transparent
	EventBus.subject_something_update.connect(subject_change_property)
	#recolor blocks: after color is changed
	EventBus.update_subject_color.connect(_block_set_color)
func _set_position() -> void:
	for i in coord_arr.size():
		if coord_arr[i] == Vector2i(0, 0):
			color_rect_arr[i].hide()
		else:
			color_rect_arr[i].position.x = coord_arr[i].x * Global.TILE_SIZE.x - BLOCK_SIZE/2
			color_rect_arr[i].position.y = coord_arr[i].y * Global.TILE_SIZE.y - BLOCK_SIZE/2
	_block_set_color(0)

#controls for keyboard specifically
func _control_type_1_subject_movement(delta: float) -> void:
	if Input.is_action_just_pressed("Left"):
		ideal_arr[0].x -= Global.TILE_SIZE.x
	if Input.is_action_just_pressed("Right"):
		ideal_arr[0].x += Global.TILE_SIZE.x
	if Input.is_action_just_pressed("Up"):
		ideal_arr[0].y -= Global.TILE_SIZE.y
	if Input.is_action_just_pressed("Down"):
		ideal_arr[0].y += Global.TILE_SIZE.y
	var input_dir := Input.get_vector("Left", "Right", "Up", "Down")
	if input_dir != Vector2.ZERO:
		key_repeat_timer += delta
		if key_repeat_timer >= key_repeat_wait_time:
			ideal_arr[0] += ceil(input_dir) * Global.TILE_SIZE
			key_repeat_wait_time = 0.05
			key_repeat_timer = 0
		_tween_position_property()
	else:
		key_repeat_timer = 0
		key_repeat_wait_time = 0.3


#tween position to be on the grid after stopped dragging
func _position_tween_to_grid() -> void:
	Global.previous_mdi = Global.mouse_dragging_item
	Global.mouse_dragging_item = -1
	ideal_arr[0] = ideal_arr[0].snapped(Global.TILE_SIZE)
	_tween_position_property()

#subject change actions, tweening shtuffs
func _rotate() -> void:
	ideal_arr[1] += ideal_arr[3] * int(Global.ROTATION_DEGREES_AMOUNT)
	ideal_arr[2] -= ideal_arr[3] * int(Global.ROTATION_DEGREES_AMOUNT)
	match Global.animations_type[0]:
		0, 1:
			var tweener : Tween = get_tree().create_tween()
			tweener.tween_property(node_arr[0], "rotation_degrees", ideal_arr[1], 0.3)
			_block_tweening("rotation_degrees", ideal_arr[2], (1 - Global.animations_type[0]) * 0.3)
		2:
			node_arr[0].rotation_degrees = ideal_arr[1]
func _flip() -> void:
	ideal_arr[3] *= -1
	var tweener : Tween = get_tree().create_tween()
	var duration: float
	match Global.animations_type[1]:
		0:
			duration = 0.15
			tweener.tween_property(node_arr[1], "scale", Vector2(0, 0), 0.15)
		1:
			duration = 0.3
		2:
			duration = 0
	tweener.tween_property(node_arr[1], "scale", Vector2(float(ideal_arr[3]), 1), duration)
	node_arr[0].rotation_degrees = ideal_arr[1]
	_block_tweening("rotation_degrees", ideal_arr[2], 0)
func _click(reset: bool) -> void:
	var mult : float = 1
	if reset:
		match Global.animations_type[2]:
			0:
				mult = 1.05
			1:
				mult = 0.9
			2:
				mult = 1
	_block_tweening("scale", Vector2(mult, mult), 0.1)
func _tween_position_property(duration: float = 0.1) -> void:
	var tweener: Tween = get_tree().create_tween()
	match Global.animations_type[3]:
		0:
			tweener.tween_property(self, "global_position", Vector2(ideal_arr[0].x, ideal_arr[0].y), duration)
		1:
			tweener.tween_property(self, "global_position", ideal_arr[0].snapped(Global.TILE_SIZE), duration)
		2:
			tweener.tween_property(self, "global_position", ideal_arr[0].snapped(Global.TILE_SIZE), 0)
func _transparent() -> void:
	color.a = 1.8 - color.a
	_block_set_color()

#dragging shtuffs
func _dragging() -> void:
	is_dragging = not is_dragging
	ideal_arr[0] = global_position
	_block_set_color()
	_z_ordering()
	if Global.mouse_dragging_item == self_number:
		_position_tween_to_grid()
	else:
		Global.mouse_dragging_item = self_number
	_click(is_dragging)
func _stop_dragging(selected_num: int) -> void:
	if selected_num == self_number:
		is_dragging = not is_dragging
		_z_ordering()
		_position_tween_to_grid()
		_block_tweening("scale", Vector2(1, 1), 0.1)
func _z_ordering() -> void:
	if is_dragging:
		get_parent().move_child(self, 0) #sets its own draw order to the lowest
		z_index += 1 #changes z index so it is above all blocks
	else:
		z_index = 0
		get_parent().move_child(self, self_number) #sets its own draw order higher

#block doing shtuffs
func _block_tweening(type: String, final_val: Variant, duration: float, color_rect_0_final_val: Variant = final_val) -> void:
	var rect_tween0 : Tween = get_tree().create_tween()
	rect_tween0.tween_property(color_rect_0, type, color_rect_0_final_val, duration)
	for i in color_rect_arr.size():
		var rect_tween : Tween = get_tree().create_tween()
		rect_tween.tween_property(color_rect_arr[i], type, final_val, duration)
func _block_set_color(duration: float = 0.3, rect_0_minus_color: float = 0.2, rect_other: float = 0) -> void:
	var color_rect_0_color: Color = Color(color.r - rect_0_minus_color, color.g - rect_0_minus_color, color.b - rect_0_minus_color, color.a)
	var color_rect_other_color: Color = Color(color.r - rect_other, color.g - rect_other, color.b - rect_other, color.a)
	match Global.animations_type[4]:
		0:
			duration *= 4
		1:
			duration = duration
		2:
			duration = 0
	_block_tweening("color", color_rect_other_color, duration, color_rect_0_color)
func _on_detector_color_rect_mouse(in_area: bool) -> void:
	if not Global.control_type == 1:
		if not is_dragging:
			if in_area:
				_block_set_color(0.3, 0.3, 0.1)
			else:
				_block_set_color()
		is_touching_mouse = in_area

#subject copy/pasting thingy
func subject_info_dump(subject_num: int) -> void:
	if subject_num == self_number:
		Global.subject_info = [position, ideal_arr[1], ideal_arr[3]]
func subject_info_grab(subject_num: int) -> void:
	if subject_num == self_number:
		position = Global.subject_info[0]
		ideal_arr[1] = Global.subject_info[1]
		ideal_arr[3] = Global.subject_info[2]
		node_arr[0].rotation_degrees = ideal_arr[1]
		node_arr[1].scale.x = ideal_arr[3]

#controls input from the ui
func subject_change_property(type: String) -> void:
	if type == "Transparent":
		_transparent()
	elif Global.current_popup_page == "" and\
	(Global.mouse_dragging_item == self_number\
	or Global.mouse_dragging_item == -1):
		match type:
			"Rotate":
				_rotate()
			"Flip":
				_flip()
