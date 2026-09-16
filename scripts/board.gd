extends Node2D

const LABEL_IMG = preload("res://resources/Label_img.tres")
var tiles: Array = [
	[
		"JAN", "FEB", "MAR", "APR", "MAY", "JUN", "WRG",
		"JUL", "AUG", "SEP", "OCT", "NOV", "DEC", "BBD",
		"1"  , "2"  , "3"  , "4"  , "5"  , "6"  , "7"  ,
		"8"  , "9"  , "10" , "11" , "12" , "13" , "14" ,
		"15" , "16" , "17" , "18" , "19" , "20" , "21" ,
		"22" , "23" , "24" , "25" , "26" , "27" , "28" ,
		"29" , "30" , "31" , "SUN", "MON", "TUE", "WED",
		"."  , "."  , "."  , "."  , "THU", "FRI", "SAT",
	],
	[
		"" , "" , "" , "" , "" , "" , "WRG",
		"" , "" , "" , "" , "" , "" , "BBD",
		"" , "" , "" , "" , "" , "" , ""   ,
		"" , "" , "" , "" , "" , "" , ""   ,
		"" , "" , "" , "" , "" , "" , ""   ,
		"" , "" , "" , "" , "" , "" , ""   ,
		"" , "" , "" , "" , "" , "" , ""   ,
		".", ".", ".", ".", "" , "" , ""   ,
	],
]
var tileset_num: int = 0


@onready var vb: VBoxContainer = $VB

@export var wrb: CompressedTexture2D
@export var bbd: CompressedTexture2D

var col_count: int = 0


func _ready() -> void:
	_create_board()

func _create_board() -> void:
	position.x = Global.BOARD_SIZE.x * -Global.TILE_SIZE.x / 2
	position.y = (Global.BOARD_SIZE.y + 1) * -Global.TILE_SIZE.y / 2
	for row_count: int in Global.BOARD_SIZE.y:
		_create_row(row_count)


func _create_row(row_count: int) -> void:
	var new_hb: HBoxContainer = HBoxContainer.new()
	new_hb.name = "HB" + str(row_count)
	col_count = 0
	while col_count < Global.BOARD_SIZE.x:
		new_hb.add_child(_create_block(row_count))
	vb.add_child(new_hb)


func _create_block( row_count: int) -> Label:
	var new_label: Label = Label.new()
	new_label.name = "Label" + str(col_count)
	new_label.text = tiles[tileset_num][col_count + row_count * 7]
	new_label.theme = preload("res://resources/new_theme.tres")
	new_label.custom_minimum_size = Global.TILE_SIZE
	new_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	new_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	match tiles[tileset_num][col_count + row_count * 7]:
		"WRG":
			_replace_with_txt_and_img(new_label, wrb, 0.075)
		"BBD":
			_replace_with_txt_and_img(new_label, bbd, 0.08)
		".":
			_replace_with_txt_and_img(new_label)
			new_label.text = "WHITE RABBIT GAMEWORKS"
			new_label.custom_minimum_size.x = Global.TILE_SIZE.x * 4
			col_count += 3
	col_count += 1
	return new_label


func _replace_with_txt_and_img(new_label: Label, img_texture: Texture2D = null, scales: float = 0) -> Label:
	var new_img: Sprite2D = Sprite2D.new()
	new_img.texture = img_texture
	new_label.add_child(new_img)
	new_img.scale *= scales
	new_img.position = Global.TILE_SIZE / 2
	new_label.add_theme_font_size_override("font_size", 26)
	new_label.add_theme_stylebox_override("normal", LABEL_IMG)
	new_label.add_theme_color_override("font_color", Color("WHITE"))
	return new_label
