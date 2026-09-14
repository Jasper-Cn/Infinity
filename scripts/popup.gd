extends CanvasLayer
class_name PopupUI

@export var popup_name : String = ""

var roots: Array = ["Settings", "Credits"]
var is_root: bool = false


func _ready() -> void:
	EventBus.settings_pages.connect(_show_page)
	hide()


func _show_page() -> void:
	if Global.current_popup_page == popup_name:
		show()
	else:
		hide()


func _on_back_button_pressed() -> void:
	on_settings_button_pressed()


func on_settings_button_pressed() -> void:
	is_root = false
	for i: int in roots.size():
		if Global.current_popup_page == roots[i]:
			Global.current_popup_page = ""
			EventBus.settings_pages.emit()
			is_root = true
			break
	if not is_root:
		Global.current_popup_page = roots[0]
		EventBus.settings_pages.emit()
