extends Node

const GAME = preload("res://scenes/game.tscn")
const SETTINGS = preload("res://scenes/settings.tscn")
const TILE_SIZE = Vector2(90, 90)

var debug_mode : bool = true
var mouse_dragging_item: int = -1
var previous_mdi: int = mouse_dragging_item
var current_popup_page: String
var animations_type: Array = [0, 0, 1, 0]
var control_type: int = 0
