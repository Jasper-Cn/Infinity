extends Node2D

@export var label: Label

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





# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
