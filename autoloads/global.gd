extends Node

const GAME = preload("res://scenes/game.tscn")
const SETTINGS = preload("res://scenes/settings.tscn")
const TILE_SIZE = Vector2(90, 90)

var debug_mode : bool = true
var mouse_dragging_item: Node = null
var current_popup_page: String
var animations_type: Array = [0, 0, 1]
