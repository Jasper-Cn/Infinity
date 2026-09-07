extends Node2D

# button references
@onready var tutorial_button: Button = $CanvasLayer/VB/TutorialButton
@onready var quick_start_button: Button = $CanvasLayer/VB/QuickStartButton
@onready var settings_button: Button = $CanvasLayer/VB/SettingsButton
@export var credits_button: Button
@onready var settings_menu: CanvasLayer = $Settings
@export var credits: CanvasLayer

func _button_pressed(source: BaseButton) -> void:
	match source:
		tutorial_button:
			SceneManager.change_scene_to(Global.TUTORIAL)
		quick_start_button:
			SceneManager.change_scene_to(Global.GAME)
		settings_button:
			settings_menu.show()
		credits_button:
			credits.show()
			
