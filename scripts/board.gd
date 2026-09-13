extends Node2D

const tiles = [
	"JAN", "FEB", "MAR", "APR", "MAY", "JUN", "WRG",
	"JUL", "AUG", "SEP", "OCT", "NOV", "DEC", "BBD",
	"1"  , "2"  , "3"  , "4"  , "5"  , "6"  , "7"  ,
	"8"  , "9"  , "10" , "11" , "12" , "13" , "14" ,
	"15" , "16" , "17" , "18" , "19" , "20" , "21" ,
	"22" , "23" , "24" , "25" , "26" , "27" , "28" ,
	"29" , "30" , "31" , "SUN", "MON", "TUE", "WED",
	"."  , "."  , "."  , "."  , "THU", "FRI", "SAT",
]

@onready var vb: VBoxContainer = $VB
const BOARD_SIZE = Vector2(7, 9)
var j: int = 0
@export var wrb: CompressedTexture2D
@export var bbd: CompressedTexture2D
const LABEL_IMG = preload("res://resources/Label_img.tres")



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = BOARD_SIZE * Global.TILE_SIZE / -2
	var hb_arr: Array = []
	for i in 8:
		var new_hb: HBoxContainer = HBoxContainer.new()
		new_hb.name = "HB" + str(i)
		j = 0
		while j < 7:
			var new_label: Label = Label.new()
			new_label.name = "Label" + str(j)
			new_label.text = tiles[j + i * 7]
			new_label.theme = preload("res://resources/new_theme.tres")
			new_label.custom_minimum_size = Global.TILE_SIZE
			if tiles[j + i * 7] == "WRG":
				_replace_with_img(new_label, wrb, 0.075)
			if tiles[j + i * 7] == "BBD":
				_replace_with_img(new_label, bbd, 0.08)
			elif tiles[j + i * 7] == ".":
				_replace_with_img(new_label)
				new_label.text = "WHITE RABBIT GAMEWORKS"
				new_label.custom_minimum_size.x = Global.TILE_SIZE.x * 4
				j += 3
			new_hb.add_child(new_label)
			new_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			new_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			j += 1
		vb.add_child(new_hb)
		hb_arr.append(new_hb)
	pass


func _replace_with_img(new_label: Label, img_texture: Texture2D = null, scales: float = 0) -> Label:
	var new_img: Sprite2D = Sprite2D.new()
	new_img.texture = img_texture
	new_label.add_child(new_img)
	new_img.scale *= scales
	new_img.position = Global.TILE_SIZE / 2
	new_label.add_theme_font_size_override("font_size", 26)
	new_label.add_theme_stylebox_override("normal", LABEL_IMG)
	new_label.add_theme_color_override("font_color", Color("WHITE"))
	return new_label

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
