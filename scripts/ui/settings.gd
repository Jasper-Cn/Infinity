extends PopupUI

@export var animations_button: Button
@export var sfx_slider: HSlider
@export var copy_button: Button
@export var paste_button: Button
@export var timer: Timer

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


func _on_copy_button_pressed() -> void:
	var full_subject_info: Array
	for i in 10:
		EventBus.get_subject_info.emit(i)
		Global.subject_info[0] /= 90
		Global.subject_info[0] += int(floor(float(Global.BOARD_SIZE.x)/2))
		Global.subject_info[1] /= 90
		Global.subject_info[1] += int(floor(float(Global.BOARD_SIZE.y)/2))
		Global.subject_info[2] %= 360
		Global.subject_info[2] /= 90
		if Global.subject_info[2] < 0:
			Global.subject_info[2] = 4 + Global.subject_info[1]
		if Global.subject_info[3] == -1:
			Global.subject_info[3] = 1
		else:
			Global.subject_info[3] = 0
		full_subject_info.append(Global.subject_info)
		#print(Global.subject_info)
	DisplayServer.clipboard_set(str(full_subject_info))
	copy_button.text = "copied!"
	timer.start()


func _on_timer_timeout() -> void:
	copy_button.text = "Copy arrangement"
	paste_button.text = "Paste arrangement"


func _on_paste_button_pressed() -> void:
	var pasted_subject_info: Variant = str_to_var(DisplayServer.clipboard_get())
	if pasted_subject_info is Array:
		paste_button.text = "pasted!"
		EventBus.set_subject_info.emit(pasted_subject_info)
	else:
		paste_button.text = "Pasted invalid text"
	timer.start()
