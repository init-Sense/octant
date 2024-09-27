extends Node

#region INSPECTOR
@export var debug_mode: bool = false

var _groups: Array[SoundGroup] = []
@export var groups: Array[SoundGroup]:
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
	_debug_print("Initializing SoundManager...")
	audio_players.clear()
	for group in _groups:
		if group is SoundGroup:
			_debug_print("Processing group: " + group.key)
			audio_players[group.key] = {}
			for sound in group.sounds:
				if sound is Sound:
					_debug_print("Processing sound: " + sound.key + " in group: " + group.key)
					var player = AudioStreamPlayer.new()
					player.stream = sound.stream
					player.bus = group.bus
					add_child(player)
					audio_players[group.key][sound.key] = player
	_debug_print("SoundManager initialization complete. Total groups: " + str(_groups.size()))
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

func play_varied(group_key: String, sound_key: String, volume: float = 0.0, pitch: float = 1.0):
	_debug_print("Attempting to play sound with variation: " + group_key + "/" + sound_key)
	if audio_players.has(group_key) and audio_players[group_key].has(sound_key):
		var player = audio_players[group_key][sound_key]
		player.volume_db = volume
		player.pitch_scale = pitch
		player.play()
		_debug_print("Sound played successfully with volume " + str(volume) + " and pitch " + str(pitch))
	else:
		print("Sound not found: " + group_key + "/" + sound_key)

func play_from(group_key: String, sound_key: String, from: float, to: float):
	_debug_print("Attempting to play sound from " + str(from) + " to " + str(to) + ": " + group_key + "/" + sound_key)
	if audio_players.has(group_key) and audio_players[group_key].has(sound_key):
		var player = audio_players[group_key][sound_key]
		player.play(from)
		# Create a timer to stop the sound at the 'to' point
		var timer: SceneTreeTimer = get_tree().create_timer(to - from)
		timer.connect("timeout", Callable(self, "_on_play_sound_from_timeout").bind(player))
		_debug_print("Sound played successfully from " + str(from) + " to " + str(to))
	else:
		print("Sound not found: " + group_key + "/" + sound_key)

func play_from_varied(group_key: String, sound_key: String, volume: float = 0.0, pitch: float = 1.0, from: float = 0.0, to: float = -1.0):
	_debug_print("Attempting to play sound with variation from " + str(from) + " to " + str(to) + ": " + group_key + "/" + sound_key)
	if audio_players.has(group_key) and audio_players[group_key].has(sound_key):
		var player = audio_players[group_key][sound_key]
		player.volume_db = volume
		player.pitch_scale = pitch
		player.play(from)
		if to > from:
			var timer: SceneTreeTimer = get_tree().create_timer((to - from) / pitch)
			timer.connect("timeout", Callable(self, "_on_play_from_timeout").bind(player))
		_debug_print("Sound played successfully with volume " + str(volume) + " and pitch " + str(pitch) + " from " + str(from) + " to " + str(to))
	else:
		print("Sound not found: " + group_key + "/" + sound_key)

func _on_play_sound_from_timeout(player: AudioStreamPlayer):
	player.stop()

func stop(group_key: String, sound_key: String):
	if audio_players.has(group_key) and audio_players[group_key].has(sound_key):
		audio_players[group_key][sound_key].stop()
	else:
		print("Sound not found: " + group_key + "/" + sound_key)

func change_bus_volume(bus_name: String, amount: float):
	var bus_index: int = AudioServer.get_bus_index(bus_name)
	if bus_index != -1:
		var current_volume: float = AudioServer.get_bus_volume_db(bus_index)
		AudioServer.set_bus_volume_db(bus_index, current_volume + amount)
		_debug_print("Changed " + bus_name + " bus volume by " + str(amount) + " dB")
	else:
		print("Bus not found: " + bus_name)

func change_volume(group_key: String, sound_key: String, volume: float):
	if audio_players.has(group_key) and audio_players[group_key].has(sound_key):
		audio_players[group_key][sound_key].volume_db = volume
		_debug_print("Changed volume of " + group_key + "/" + sound_key + " to " + str(volume) + " dB")
	else:
		print("Sound not found: " + group_key + "/" + sound_key)
#endregion

#region UTILS
func is_playing(group_key: String, sound_key: String) -> bool:
	if audio_players.has(group_key) and audio_players[group_key].has(sound_key):
		return audio_players[group_key][sound_key].playing
	else:
		print("Sound not found: " + group_key + "/" + sound_key)
		return false

func _debug_print(message: String):
	if debug_mode:
		print(message)
#endregion
