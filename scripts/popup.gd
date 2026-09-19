extends CanvasLayer
class_name PopupUI

@export var popup_name : String = ""
@export var panel: Panel

var roots: Array = ["Settings", "Credits"]
var is_root: bool = false
var max_scroll: float

func _ready() -> void:
	EventBus.on_settings_button_pressed.connect(on_settings_button_pressed)
	EventBus.settings_pages.connect(_show_page)
	max_scroll = get_viewport().size.y - panel.size.y
	#print(popup_name + " viewport size: " + str(get_viewport().size.y))
	#print(popup_name + " panel size: " + str(panel.size.y))
	#print(popup_name + ": " + str(max_scroll))
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
