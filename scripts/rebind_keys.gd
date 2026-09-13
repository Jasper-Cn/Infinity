extends PopupUI

@export var panel: Panel

var rebinding_key : String
var is_rebinding : bool
var rebinding_button : Button
var max_scroll: float 
var prev_event: InputEvent
func _ready() -> void:
	super()
	max_scroll = get_viewport().size.y - panel.size.y


func _rebind_button_pressed(source_id: Object, source_name: String) -> void:
	if not is_rebinding:
		rebinding_key = source_name
		InputMap.action_erase_events(rebinding_key)
		rebinding_button = source_id
		rebinding_button.modulate.r = 0
		is_rebinding = true

func _unhandled_input(event: InputEvent) -> void:
	if Global.current_popup_page == popup_name:
		if is_rebinding:
			var key : Key
			if event is InputEventKey:
				key = event.keycode
				rebinding_button.text = str(OS.get_keycode_string(key))
			elif event is InputEventMouseButton:
				rebinding_button.text = event.as_text()
			else:
				return
			InputMap.action_add_event(rebinding_key, event)
			rebinding_button.modulate.r = 1
			is_rebinding = false
			rebinding_button.mouse_filter = Control.MOUSE_FILTER_STOP
			EventBus.update_UI.emit("labels")
		else:
			if event.as_text() == "Mouse Wheel Up" and panel.position.y < 0:
				panel.position.y += 10
			elif event.as_text() == "Mouse Wheel Down" and panel.position.y > max_scroll:
				panel.position.y -= 10
