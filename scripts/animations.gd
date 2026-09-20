extends PopupUI


func _on_animations_button_pressed(source: Button, i: int) -> void:
	Global.animations_type[i] = text_change_3(Global.animations_type[i], source, ["full", "minimal", "off"])
