extends Node


const START = preload("res://scenes/start.tscn")
const GAME = preload("res://scenes/game.tscn")
const SETTINGS = preload("res://scenes/settings.tscn")
const TUTORIAL = preload("res://scenes/cutscene_tutorial.tscn")


var debug_mode : bool = true
var mouse_dragging_item: Node = null
var current_popup_page: String
var animations: bool = true
