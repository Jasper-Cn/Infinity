extends PopupUI

var subjects: Node2D
@export var node_2d: Node2D


func _ready() -> void:
	EventBus.get_refference.connect(get_ref)
	super()


func _on_color_picker_button_color_changed(color: Color, subject_num: int) -> void:
	subjects.get_child(subject_num).color = color
	EventBus.update_subject_color.emit()


func _block_set_color_picker_color(num: int) -> void:
	node_2d.get_child(num).get_child(2).color = subjects.get_child(num).color


func _on_reset_pressed(subject_num: int) -> void:
	subjects.get_child(subject_num).color = subjects.get_child(subject_num).default_color
	node_2d.get_child(subject_num).get_child(2).color = subjects.get_child(subject_num).default_color
	EventBus.update_subject_color.emit()


func get_ref(ref: Node, name_of: String) -> void:
	if name_of == "subjects":
		subjects = ref
		for i in node_2d.get_child_count():
			_block_set_color_picker_color(i)
