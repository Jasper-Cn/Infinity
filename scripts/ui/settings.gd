extends PopupUI

@export var animations_button: Button
@export var sfx_slider: HSlider

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
