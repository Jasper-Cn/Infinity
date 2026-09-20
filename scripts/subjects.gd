extends Node2D

@export var timer: Timer


func _on_timer_timeout() -> void:
	EventBus.get_refference.emit(self, self.name)
