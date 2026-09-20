extends CanvasLayer
class_name PopupUI

@export var popup_name : String = ""
@export var panel: Panel

var roots: Array = ["Settings", "Credits"]
var is_root: bool = false
var max_scroll: float


func _ready() -> void:
	
	EventBus.settings_pages.connect(_show_page)
	max_scroll = get_viewport().size.y - panel.size.y
	hide()


func _process(delta: float) -> void:
	if Global.current_popup_page == popup_name:
		if Input.is_action_just_pressed("zoom in") and panel.position.y < 0:
			panel.position.y += 1000 * delta
		elif Input.is_action_just_pressed("zoom out") and panel.position.y > max_scroll:
				panel.position.y -= 1000 * delta


func _show_page() -> void:
	if Global.current_popup_page == popup_name:
		show()
	else:
		hide()


func _on_back_button_pressed() -> void:
	EventBus.on_settings_button_pressed.emit()





func text_change_3(type: Variant, source: Node, texts: Array) -> Variant:
	type += 1
	type %= 3
	source.text = texts[type]
	return type
