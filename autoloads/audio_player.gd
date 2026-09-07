extends Node2D

var current_player :AudioStreamPlayer = null
@export var sound_effects: Array[SFX] = []

var sound_effect_dict: Dictionary = {}

# MUSIC: only one song can play at a time, it will override, Music bus
# SFX: can play simultaneously, SFX bus

# THIS BLOCK HANDLES GLOBAL BUTTON AUDIO
# lambda function activates whenever a node is added, if it is a button, then the pressed signal is connected to the _play_click_sound function
func _enter_tree() -> void:
	get_tree().node_added.connect(func (node: Node) -> void:
		if node is BaseButton:
			node.pressed.connect(_play_click_sound))

func _play_click_sound() -> void:
	play_sfx(SFX.SOUND_EFFECT_TYPES.BUTTON_DOWN)
	
	
func _ready() -> void:
	# associates the enum type with the actual file in a dict
	for sfx in sound_effects:
		sound_effect_dict[sfx.type] = sfx
	


		
# NOTE: VOLUME IS A PERCENTAGE BETWEEN 0 AND 1
func play_sfx(type : SFX.SOUND_EFFECT_TYPES) -> void:
	var new_player : AudioStreamPlayer= AudioStreamPlayer.new()
	var sfx : SFX = sound_effect_dict[type]
	new_player.stream = sfx.sound_effect
	new_player.name = str(type) + " SFX Player"
	new_player.bus = "SFX"

	# Use volume linear for it to work with bus
	new_player.pitch_scale = sfx.pitch_scale
	new_player.pitch_scale += randf_range(-sfx.pitch_randomness, sfx.pitch_randomness)
	new_player.volume_db = linear_to_db(sfx.volume)
	add_child(new_player)
	new_player.play()
	new_player.finished.connect(new_player.queue_free)


func play_music(Stream : AudioStream, Volume : float) -> void:
	if current_player:
		if Stream == current_player.stream:
			return
		current_player.queue_free()
	var musicPlayer : AudioStreamPlayer= AudioStreamPlayer.new()
	musicPlayer.stream = Stream
	musicPlayer.name = "Music Player"
	musicPlayer.volume_db = Volume
	musicPlayer.bus = "Music"
	add_child(musicPlayer)
	
	musicPlayer.play()
	current_player = musicPlayer
	musicPlayer.finished.connect(musicPlayer.queue_free)
	
