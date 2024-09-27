extends Node

#region INSPECTOR
@export var debug_mode: bool = false

var _groups: Array[AudioManagerGroup] = []
@export var groups: Array[AudioManagerGroup]:
	get:
		return _groups
	set(value):
		_groups = value
		_initialize_audio_players()

var audio_players: Dictionary = {}
#endregion


#region LIFECYCLE
func _ready():
	_initialize_audio_players()

func _initialize_audio_players():
	_debug_print("Initializing AudioManager...")
	audio_players.clear()
	for group in _groups:
		if group is AudioManagerGroup:
			_debug_print("Processing group: " + group.key)
			audio_players[group.key] = {}
			for sound in group.sounds:
				if sound is AudioManagerSound:
					_debug_print("Processing sound: " + sound.key + " in group: " + group.key)
					var player = AudioStreamPlayer.new()
					player.stream = sound.stream
					player.bus = group.bus
					add_child(player)
					audio_players[group.key][sound.key] = player
	_debug_print("AudioManager initialization complete. Total groups: " + str(_groups.size()))
	_debug_print("Final audio_players dictionary: " + str(audio_players))
#endregion


#region CONTROLS
func play(group_key: String, sound_key: String):
	_debug_print("Attempting to play sound: " + group_key + "/" + sound_key)
	if audio_players.has(group_key) and audio_players[group_key].has(sound_key):
		audio_players[group_key][sound_key].play()
		_debug_print("Sound played successfully: " + group_key + "/" + sound_key)
	else:
		print("Sound not found: " + group_key + "/" + sound_key)
		_debug_print("Available groups: " + str(audio_players.keys()))
		if audio_players.has(group_key):
			_debug_print("Available sounds in group " + group_key + ": " + str(audio_players[group_key].keys()))

func stop(group_key: String, sound_key: String):
	if audio_players.has(group_key) and audio_players[group_key].has(sound_key):
		audio_players[group_key][sound_key].stop()
	else:
		print("Sound not found: " + group_key + "/" + sound_key)
#endregion


#region UTILS
func is_sound_playing(group_key: String, sound_key: String) -> bool:
	if audio_players.has(group_key) and audio_players[group_key].has(sound_key):
		return audio_players[group_key][sound_key].playing
	else:
		print("Sound not found: " + group_key + "/" + sound_key)
		return false

func _debug_print(message: String):
	if debug_mode:
		print(message)
#endregion
