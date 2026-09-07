
extends Node2D

@onready var tutorial_label: Label = $CanvasLayer/TutorialLabel
@onready var tutorial_sprite: Sprite2D = $CanvasLayer/TutorialImage
@onready var start_button: Button = $CanvasLayer/StartButton

var current_step : int = 0
const GAME = preload("res://scenes/game.tscn")

var tutorial_data : Array = [
	{
		"text":"you are an avid nature photographer",
		"image_path":"res://stock/input-prompts/Controller Icons/generic_button.svg"
	},
	{
		"text":"too bad you are BROKE!!!",
		"image_path":"res://stock/input-prompts/Controller Icons/generic_button_circle.svg"
	},
	{
		"text":"are we broke or is the broke broking us",
		"image_path":"res://stock/input-prompts/Controller Icons/generic_button_trigger_a_fill.svg"
	},
]
func _ready() -> void:
	loadIndexItems(0, false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_released("click") or Input.is_action_just_released("ui_accept"):
		# Subtracts -1 prevents OBO error
		# .size() is not zero indexed but current_step is
		
		# Can start at one since the 0 loads at ready()
		current_step += 1
		if not current_step > tutorial_data.size() - 1:
			loadIndexItems(current_step, true)


func loadIndexItems(index: int, is_fading: bool) -> void:
	if not tutorial_data[index]["image_path"]:
		printerr("Image Texture Doesn't Exist")
	# print(tutorial_data[index]["image_path"])
	if is_fading:
		await Fade.fade(1, 0.2).finished
		tutorial_sprite.texture = load(tutorial_data[index]["image_path"])
		if current_step == tutorial_data.size() - 1:
			# shows start button to start game
			start_button.show()
			$CanvasLayer/ClickToContinueLabel.hide()
		tutorial_label.text = tutorial_data[index]["text"]
		await Fade.fade(0, 0.2).finished
	else:
		# just load it without tweeners
		tutorial_label.text = tutorial_data[index]["text"]
		tutorial_sprite.texture = load(tutorial_data[index]["image_path"])

func _on_start_button_pressed() -> void:
	print("Starting game, from tutorial cutscene")
	SceneManager.change_scene_to(Global.GAME)
