extends CanvasLayer

@export var settings: Label
@export var rotate: Label
@export var flip: Label
@export var transparency: Label
@export var ui: Label

var label_arr : Array
var label_text_arr : Array = [
	"open settings",
	"rotate " + str(int(Global.ROTATION_DEGREES_AMOUNT)) +  " degrees",
	"flip",
	"make semi-transparent",
	"show/hide the UI",
]

func _ready() -> void:
	label_arr = [settings, rotate, flip, transparency, ui]
	EventBus.update_UI.connect(_UI_update)
	_UI_update("labels")


func _UI_update(update_item: String) -> void:
	if update_item == "visibility":
		self.visible = not self.visible
	if update_item == "labels":
		for i in label_arr.size():
			var key : String = InputMap.action_get_events(label_arr[i].name)[0].as_text().replace(" - Physical", "")
			var latter : String = label_text_arr[i]
			var text : String = key + " = " + latter
			label_arr[i].text = text
