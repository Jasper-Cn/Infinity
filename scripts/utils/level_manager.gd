extends Node2D

@export var levels: Array[PackedScene]
var current_level_index : int = 0
var current_level : Node

signal game_complete

func _ready() -> void:
	Global.game_state = Global.game_states.GAME
	_load_level(0)

# recieve a signal
func _on_phone_recieved(area: Area2D) -> void:
	print("phone recieved from levelmanager!!")
	# Start new level here
	current_level_index += 1
	# we can do additional checks if the level was really completed here
	EventBus.level_completed.emit(current_level_index)
	await Global.fade_node.fade(1).finished

	if _load_level(current_level_index):
		EventBus.start_next_level.emit()
		Global.fade_node.fade(0)
	else:
		print("itz the end of the game")
		game_complete.emit()

	# add connecting signals and stuff here

func _load_level(level_number : int) -> bool:
	var level : Node
	
	if current_level:
		current_level.queue_free()

	if levels.size() > level_number:
		level = levels[level_number].instantiate()
		add_child(level)
	else:
		return false
	current_level = level
	return true

'''
func _connect_charger_signals() -> void:
	var chargers : Array = get_tree().get_nodes_in_group("charger")
	if !chargers:
		print("no charger reference in this level")
	
	for charger : Charger in chargers:
		print("connecting charger")
		charger.phone_recieved.connect(_on_phone_recieved)
'''
