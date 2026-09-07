extends CanvasLayer


@onready var color_rect: ColorRect = $ColorRect

func _ready() -> void:
	color_rect.modulate.a = 0

# takes alpha target as first parameter, 0 is clear and 1 is opaque
func fade(alpha_target : float, duration : float = .2) -> Tween:
	# alpha target most be between 0 and 1
	print("FADING")
	var tweener : Tween = get_tree().create_tween()
	tweener.tween_property(color_rect, "modulate:a", alpha_target, duration)
	return tweener
