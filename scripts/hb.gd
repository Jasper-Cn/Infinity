extends HBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in get_child_count():
		get_child(i).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		get_child(i).vertical_alignment = VERTICAL_ALIGNMENT_CENTER


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
