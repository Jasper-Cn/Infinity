extends Node2D
class_name Subject


@export var color: Color = Color("WHITE")
@export var self_number: int
@onready var color_rect_0: ColorRect = $Node2D/ColorRect0
@onready var color_rect_1: ColorRect = $Node2D/ColorRect1
@onready var color_rect_2: ColorRect = $Node2D/ColorRect2
@onready var color_rect_3: ColorRect = $Node2D/ColorRect3
@onready var color_rect_4: ColorRect = $Node2D/ColorRect4
@export var coord_1: Vector2
@export var coord_2: Vector2
@export var coord_3: Vector2
@export var coord_4: Vector2
@export var ap_rotation: AnimationPlayer
@export var ap_flip: AnimationPlayer
@onready var node_2d: Node2D = $Node2D
@onready var label: Label = $Label

var is_dragging: bool = false
var is_touching_mouse: bool = false
var coord_arr: Array
var rect_arr: Array
var ideal_rotation_degrees: int
var ideal_scale_x: int = 1


func _ready() -> void:
	label.text = str(self_number)
	coord_arr = [coord_1, coord_2, coord_3, coord_4]
	rect_arr = [color_rect_1, color_rect_2, color_rect_3, color_rect_4]
	#hide()
	EventBus.update_subject_color.connect(_set_color)
	_set_color()

func _physics_process(_delta: float) -> void:
	if Global.current_popup_page == "":
		if visible:
			if is_dragging:
				_set_color()
				z_index += 1
				global_position = get_global_mouse_position()
				global_position = global_position.snapped(Global.TILE_SIZE)
				if Input.is_action_just_pressed("Rotate"):
					#ideal_rotation_degrees = int(ideal_rotation_degrees) % 360
					#rotation_degrees = ideal_rotation_degrees
					ideal_rotation_degrees += 90
					if Global.animations_type[0] < 2:
						#if ap_rotation.is_playing():
							#ap_rotation.stop()
						#ap_rotation.play("rotate to " + str(int(ideal_rotation_degrees)))
						var tweener : Tween = get_tree().create_tween()
						tweener.tween_property(node_2d, "rotation_degrees", ideal_rotation_degrees, 0.3)
						if Global.animations_type[0] < 1:
							var rect_tween0 : Tween = get_tree().create_tween()
							rect_tween0.tween_property(color_rect_0, "rotation_degrees", -ideal_scale_x * ideal_rotation_degrees, 0.3)
							for i in rect_arr.size():
								var rect_tween : Tween = get_tree().create_tween()
								rect_tween.tween_property(rect_arr[i], "rotation_degrees", -ideal_scale_x * ideal_rotation_degrees, 0.3)
					else:
						node_2d.rotation_degrees = ideal_rotation_degrees
				if Input.is_action_just_pressed("Flip"):
					ideal_scale_x *= -1
					if Global.animations_type[1] == 0:
						#if ap_flip.is_playing():
							#ap_flip.stop()
						#ap_flip.play("Flip to " + str(int(ideal_scale_x)))
						var tweener : Tween = get_tree().create_tween()
						tweener.tween_property(node_2d, "scale", Vector2(float(0), 0), 0.15)
						tweener.tween_property(node_2d, "scale", Vector2(float(ideal_scale_x), 1), 0.15)
					elif Global.animations_type[1] == 1:
						var tweener : Tween = get_tree().create_tween()
						tweener.tween_property(node_2d, "scale", Vector2(float(ideal_scale_x), 1), 0.3)
					else:
						node_2d.scale.x = ideal_scale_x
					var rect_tween0 : Tween = get_tree().create_tween()
					await rect_tween0.tween_property(color_rect_0, "custom_minimum_size", Vector2(0, 0), 0.3).finished
					color_rect_0.rotation_degrees = -ideal_scale_x * ideal_rotation_degrees
					for i in rect_arr.size():
						rect_arr[i].rotation_degrees = -ideal_scale_x * ideal_rotation_degrees
			else:
				z_index = 0
			if Input.is_action_just_pressed("click") and is_touching_mouse:
				is_dragging = not is_dragging
				Global.mouse_dragging_item = self
				var mult : float = 0
				if is_dragging:
					if Global.animations_type[2] == 0:
						mult = 1.05
					elif Global.animations_type[2] == 1:
						mult = 0.9
					else:
						mult = 1
				else:
					mult = 1
				var rect_tween0 : Tween = get_tree().create_tween()
				rect_tween0.tween_property(color_rect_0, "scale", Vector2(mult, mult), 0.1)
				for i in rect_arr.size():
					var rect_tween : Tween = get_tree().create_tween()
					rect_tween.tween_property(rect_arr[i], "scale", Vector2(mult, mult), 0.1)
		if Input.is_action_just_pressed(str(self_number)):
			visible = not visible
		if Input.is_action_just_pressed("Transparency"):
			color.a = 1.8 - color.a
			_set_color()
	#var control := get_viewport().gui_get_hovered_control()
	#if control:
		#print("Mouse is over: ", control.get_path())

func _set_color(rect_0: float = 0.2, rect_other: float = 0) -> void:
	color_rect_0.color = Color(color.r - rect_0, color.g - rect_0, color.b - rect_0)
	for i in rect_arr.size():
		if coord_arr[i] == Vector2(0, 0):
			rect_arr[i].hide()
		else:
			rect_arr[i].position.x = coord_arr[i].x * 90 - 40
			rect_arr[i].position.y = coord_arr[i].y * 90 - 40
		rect_arr[i].color = Color(color.r - rect_other, color.g - rect_other, color.b - rect_other)
	pass

func _on_color_rect_mouse_entered() -> void:
	if not is_dragging:
		_set_color(0.3, 0.1)
	is_touching_mouse = true

func _on_color_rect_mouse_exited() -> void:
	if not is_dragging:
		_set_color()
	is_touching_mouse = false
