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
		EventBus.on_settings_button_pressed.emit()
	if Input.is_action_just_pressed("UI"):
		EventBus.update_UI.emit("visibility")


func _on_animations_button_pressed(source: Button, i: int) -> void:
	Global.animations_type[i] = text_change_3(Global.animations_type[i], source, ["full", "minimal", "off"])


func text_change_3(type: Variant, source: Node, texts: Array) -> Variant:
	type += 1
	type %= 3
	source.text = texts[type]
	return type


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
	var condensed_subject_info: String = "#"
	#var condensed_rotational_and_flip: int
	for i in Global.NUM_OF_SUBJECTS:
		EventBus.get_subject_info.emit(i)
		
		_item_0(true)
		
		condensed_subject_info += position_to_string(Global.subject_info[0])
		
		_item_1(true)
		_item_2()
		
		condensed_subject_info += str(int(Global.subject_info[1] + (Global.subject_info[2] * 360/Global.ROTATION_DEGREES_AMOUNT)))
	
	copy_to_clipboard(condensed_subject_info)
	timer.start()


func _on_paste_button_pressed() -> void:
	var pasted_subject_info: String = paste_from_clipboard().substr(1)
	if is_not_numeric(pasted_subject_info):
		return
	
	for i in Global.NUM_OF_SUBJECTS:
		var subject_info_i: String = pasted_subject_info.substr(0 + (i * 3), 3)
		var position_i: int = int(subject_info_i.substr(0, 2))
		var rotation_and_flip_i: int = int(subject_info_i.substr(2, 1))
		
		if not position_i >= Global.BOARD_SIZE.x * Global.BOARD_SIZE.y\
		and not rotation_and_flip_i >= 4 * 2 and not position_i < 0:
			
			Global.subject_info = [
				Vector2(position_i % Global.BOARD_SIZE.x, int(floor(float(position_i) / Global.BOARD_SIZE.x))),
				rotation_and_flip_i % int(360/Global.ROTATION_DEGREES_AMOUNT),
				int(floor(float(rotation_and_flip_i) / int(360/Global.ROTATION_DEGREES_AMOUNT))),
			]
			
			_item_0(false)
			
			_item_1(false)
			
			_item_2()
			
			EventBus.set_subject_info.emit(i)
	
	paste_button.text = "pasted!"
	timer.start()


func _item_0(copy: bool) -> void:
	var half_block: Vector2 = floor(Vector2(Global.BOARD_SIZE)/2)
	if copy:
		Global.subject_info[0] /= Global.TILE_SIZE
		Global.subject_info[0] += half_block
	else:
		Global.subject_info[0] -= half_block
		Global.subject_info[0] *= Global.TILE_SIZE 


func _item_1(copy: bool) -> void:
	if copy:
		Global.subject_info[1] += 720
		Global.subject_info[1] %= 360
		Global.subject_info[1] /= Global.ROTATION_DEGREES_AMOUNT
	else:
		Global.subject_info[1] *= Global.ROTATION_DEGREES_AMOUNT


func _item_2() -> void:
	if not Global.subject_info[2] == 1:
		Global.subject_info[2] = -Global.subject_info[2] - 1


func copy_to_clipboard(clipboard_info: String) -> void:
	if OS.has_feature("web") and JavaScriptBridge.has_method("eval"):
		JavaScriptBridge.eval("prompt('Copy this text:', '" + clipboard_info + "');")
	else:
		DisplayServer.clipboard_set(clipboard_info)
		copy_button.text = "copied!"


func paste_from_clipboard() -> String:
	if OS.has_feature("web") and JavaScriptBridge.has_method("eval"):
		return JavaScriptBridge.eval("prompt('Paste your text here:');")
	else:
		return DisplayServer.clipboard_get()


func is_not_numeric(text: String) -> bool:
	var regex: RegEx = RegEx.new()
	regex.compile("^[0-9-]+$")
	if not text.length() == 30 or regex.search(text) == null:
		paste_button.text = "Pasted invalid text"
		timer.start()
		return true
	return false


func position_to_string(position: Vector2) -> String:
	if position.x >= Global.BOARD_SIZE.x or position.x < 0\
	or position.y >= Global.BOARD_SIZE.y or position.y < 0:
		return "-1"
	else:
		var condensed_position: int = int(position.x + position.y * Global.BOARD_SIZE.x)
		if condensed_position < 10 and condensed_position >= 0:
			return "0" + str(condensed_position)
		return str(condensed_position)


func _on_timer_timeout() -> void:
	copy_button.text = "Copy arrangement"
	paste_button.text = "Paste arrangement"
