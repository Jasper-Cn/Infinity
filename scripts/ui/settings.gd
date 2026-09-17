extends PopupUI

@export var animations_button: Button
@export var sfx_slider: HSlider
@export var copy_button: Button
@export var paste_button: Button
@export var timer: Timer
@export var copy: TextEdit
@export var paste: TextEdit

func _ready() -> void:
	super()
	sfx_slider.value = 0.2
	_slider_value_changed(0.2, "SFX")


func _slider_value_changed(value: float, type: String) -> void:
	if !AudioServer.get_bus_index(type):
		printerr("couldn't get bus")
	var index : int = AudioServer.get_bus_index(type)
	AudioServer.set_bus_volume_db(index, linear_to_db(value))


func _on_button_pressed(button_name: String) -> void:
	Global.current_popup_page = button_name
	EventBus.settings_pages.emit()


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("Settings"):
		on_settings_button_pressed()
	if Input.is_action_just_pressed("UI"):
		EventBus.update_UI.emit("visibility")


func on_settings_button_pressed() -> void:
	super()
	_on_copy_button_pressed(true)


func _on_animations_button_pressed(source: Button, i: int) -> void:
	Global.animations_type[i] += 1
	Global.animations_type[i] %= 3
	match Global.animations_type[i]:
		0:
			source.text = "full"
		1:
			source.text = "minimal"
		2:
			source.text = "off"


func _on_control_type_button_pressed(source: BaseButton) -> void:
	Global.control_type += 1
	Global.control_type %= 3
	match Global.control_type:
		0:
			source.text = "Multi"
		1:
			source.text = "Keyboard"
		2:
			source.text = "Mouse"


func _on_copy_button_pressed(settings: bool = false) -> void:
	#var full_subject_info: Array
	var condensed_subject_info: String = "#"
	var condensed_position: int
	var condensed_rotational_and_flip: int
	for i in Global.NUM_OF_SUBJECTS:
		EventBus.get_subject_info.emit(i)
		Global.subject_info[0] /= Global.TILE_SIZE.x
		Global.subject_info[0] += int(floor(float(Global.BOARD_SIZE.x)/2))
		Global.subject_info[1] /= Global.TILE_SIZE.y
		Global.subject_info[1] += int(floor(float(Global.BOARD_SIZE.y)/2))
		if Global.subject_info[0] >= Global.BOARD_SIZE.x or Global.subject_info[0] < 0\
		or Global.subject_info[1] >= Global.BOARD_SIZE.y or Global.subject_info[1] < 0:
			condensed_position = -1
		else:
			condensed_position = Global.subject_info[0] + Global.subject_info[1] * Global.BOARD_SIZE.x
		if condensed_position < 10 and condensed_position >= 0:
			condensed_subject_info += "0"
		condensed_subject_info += str(condensed_position)
		Global.subject_info[2] %= 360
		Global.subject_info[2] /= Global.ROTATION_DEGREES_AMOUNT
		if Global.subject_info[2] < 0:
			Global.subject_info[2] = (360/Global.ROTATION_DEGREES_AMOUNT) + Global.subject_info[2]
		if Global.subject_info[3] == -1:
			Global.subject_info[3] = 1
		else:
			Global.subject_info[3] = 0
		condensed_rotational_and_flip = Global.subject_info[2] + (Global.subject_info[3] * int(360/Global.ROTATION_DEGREES_AMOUNT))
		condensed_subject_info += str(condensed_rotational_and_flip)
		if i < 9:
			condensed_subject_info += ""
	if OS.has_feature("web"):
		copy.show()
		copy_button.hide()
		paste.show()
		paste_button.hide()
		# Use JavaScriptBridge to copy text via the browser
		#if JavaScriptBridge.has_method("eval"):
			# Prompt approach: Prompts the browser to show a native dialog box 
			# where the user can copy the text manually, bypassing strict iframe blocks.
		copy.text = condensed_subject_info
	else:
		copy.hide()
		copy_button.show()
		paste.hide()
		paste_button.show()
		# Standard native desktop clipboard behavior
		DisplayServer.clipboard_set(condensed_subject_info)
		if not settings:
			copy_button.text = "copied!"
	timer.start()
	#print(condensed_subject_info)
	#print(condensed_rotational_and_flip)

func _on_timer_timeout() -> void:
	copy_button.text = "Copy arrangement"
	paste_button.text = "Paste arrangement"


func _on_paste_button_pressed() -> void:
	var pasted_subject_info: Variant = DisplayServer.clipboard_get().substr(1)
	#print(pasted_subject_info)
	var regex: RegEx = RegEx.new()
	regex.compile("^[0-9-]+$")
	if not pasted_subject_info.length() == 30 or regex.search(pasted_subject_info) == null:
		paste_button.text = "Pasted invalid text"
		timer.start()
		return
	for i in 10:
		var subject_info_i: String = pasted_subject_info.substr(0 + (i * 3), 3)
		var position_i: int = int(subject_info_i.substr(0, 2))
		var rotation_and_flip_i: int = int(subject_info_i.substr(2, 1))
		var array_i: Array = ["position.x", "position.y", "rotation_degrees", "scale.x"]
		if not position_i >= Global.BOARD_SIZE.x * Global.BOARD_SIZE.y\
		and not rotation_and_flip_i >= 4 * 2 and not position_i < 0:
			array_i[0] = (position_i % Global.BOARD_SIZE.x)
			array_i[0] -= int(floor(float(Global.BOARD_SIZE.x)/2))
			array_i[0] *= Global.TILE_SIZE.x
			array_i[1] = int(floor(float(position_i) / Global.BOARD_SIZE.x))
			array_i[1] -= int(floor(float(Global.BOARD_SIZE.y)/2))
			array_i[1] *= Global.TILE_SIZE.y
			array_i[2] = rotation_and_flip_i % int(360/Global.ROTATION_DEGREES_AMOUNT)
			array_i[2] *= Global.ROTATION_DEGREES_AMOUNT
			array_i[3] = int(floor(float(rotation_and_flip_i) / int(360/Global.ROTATION_DEGREES_AMOUNT)))
			if array_i[3] == 0:
				array_i[3] = 1
			else:
				array_i[3] = -1
			EventBus.set_subject_info.emit(i, array_i)
			paste_button.text = "pasted!"
			paste.text = ""
	timer.start()
