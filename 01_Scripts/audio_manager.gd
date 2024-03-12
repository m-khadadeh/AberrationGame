class_name AudioManager
extends Node

@export var sound_dictionary : Dictionary

@onready var muted = false
@onready var music_allowed = false
@onready var _music_player : AudioStreamPlayer = $AudioStreamPlayer

func _ready():
	pass

func toggle_mute():
	muted = not muted
	if muted:
		_music_player.stop()
	elif music_allowed:
		_music_player.play()
	else:
		_music_player.stop()

func play_sfx(sound : String):
	if not muted:
		var new_audio_player = AudioStreamPlayer.new()
		add_child(new_audio_player)
		new_audio_player.stream = sound_dictionary[sound]
		new_audio_player.finished.connect(new_audio_player.queue_free)
		new_audio_player.play()

func allow_music():
	music_allowed = true
	if not muted:
		_music_player.play()

