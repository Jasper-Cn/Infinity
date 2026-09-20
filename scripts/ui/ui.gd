extends CanvasLayer

@export var settings: Button
@export var rotate: Button
@export var flip: Button
@export var transparency: Button
@export var ui: Button

var label_arr : Array
var label_text_arr : Array = [
	"open settings",
	"rotate " + str(int(Global.ROTATION_DEGREES_AMOUNT)) +  " degrees",
	"flip horizontally",
	"make semi-transparent",
	"show/hide the UI",
]

func _ready() -> void:
	label_arr = [settings, rotate, flip, transparency, ui]
	EventBus.update_UI.connect(_UI_update)
	_UI_update("labels")


func _UI_update(update_item: String) -> void:
	if update_item == "visibility":
		visible = not visible
	if update_item == "labels":
		for i in label_arr.size():
			var key : String = InputMap.action_get_events(label_arr[i].name)[0].as_text().replace(" - Physical", "")
			var latter : String = label_text_arr[i]
			var text : String = key + " = " + latter
			label_arr[i].text = text


func _on_settings_pressed() -> void:
	EventBus.on_settings_button_pressed.emit()


func _on_subject_pressed(type: String) -> void:
	EventBus.subject_something_update.emit(type)


func _on_panel_mouse(extra_arg_0: bool) -> void:
	Global.mouse_not_over_ui_panel = extra_arg_0
