extends PopupUI


@export var panel: Panel
@export var subject: Node2D
var max_scroll: int
const GAME = preload("res://scenes/game.tscn")
@export var node_2d: Node2D


func _ready() -> void:
	super()
	max_scroll = get_viewport().size.y - panel.size.y
	for i in node_2d.get_child_count():
		_set_color_picker_color(i)


func _input(event: InputEvent) -> void:
	if Global.current_popup_page == popup_name:
		if event.as_text() == "Mouse Wheel Up" and panel.position.y < 0:
			panel.position.y += 10
		elif event.as_text() == "Mouse Wheel Down" and panel.position.y > max_scroll:
			panel.position.y -= 10


func _on_color_picker_button_color_changed(color: Color, subject_num: int) -> void:
	subject.get_child(subject_num).color = color
	EventBus.update_subject_color.emit()


func _set_color_picker_color(num: int) -> void:
	node_2d.get_child(num).get_child(1).color = subject.get_child(num).color
	pass
