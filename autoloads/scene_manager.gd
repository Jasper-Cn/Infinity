extends CanvasLayer
@export var color_rect: ColorRect

var scene_to_change_to : PackedScene

## Takes a PackedScene as parameter and changes the scene and uses fade to transition
func change_scene_to(new_scene : PackedScene) -> void:
	if new_scene:
		scene_to_change_to = new_scene
		$AnimationPlayer.play("fade_scene")
	else:
		printerr("tried to load packed_scene that doesn't exist in scene_manager")

func switch_scenes() -> void:
	get_tree().change_scene_to_packed(scene_to_change_to)
