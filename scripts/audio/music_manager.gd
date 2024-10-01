extends Node

#region INSPECTOR
@export var debug_mode: bool = false

var _groups: Array[MusicGroup] = []
@export var groups: Array[MusicGroup]:
	get:
		return _groups
	set(value):
		_groups = value
		_initialize_music_players()

var music_players: Dictionary = {}
#endregion


#region LIFECYCLE
func _ready():
	_initialize_music_players()

func _initialize_music_players():
	_debug_print("Initializing MusicManager...")
	music_players.clear()
	for group in _groups:
		if group is MusicGroup:
			_debug_print("Processing group: " + group.key)
			music_players[group.key] = {}
			for music in group.sounds:
				if music is Music:
					_debug_print("Processing music: " + music.key + " in group: " + group.key)
					music_players[group.key][music.key] = []
					for i in range(music.stems.size()):
						var player = AudioStreamPlayer.new()
						player.stream = music.stems[i]
						player.bus = group.bus
						player.volume_db = -80 if i > 0 else 0
						add_child(player)
						music_players[group.key][music.key].append(player)
	_debug_print("MusicManager initialization complete. Total groups: " + str(_groups.size()))
	_debug_print("Final music_players dictionary: " + str(music_players))
#endregion


#region CONTROLS
func play(group_key: String, music_key: String):
	_debug_print("Attempting to play music: " + group_key + "/" + music_key)
	if music_players.has(group_key) and music_players[group_key].has(music_key):
		var players = music_players[group_key][music_key]
		for i in range(players.size()):
			players[i].play()
			players[i].volume_db = 0 if i == 0 else -80
		_debug_print("Music played successfully: " + group_key + "/" + music_key)
	else:
		print("Music not found: " + group_key + "/" + music_key)

func play_layer(group_key: String, music_key: String, layer_index: int):
	if music_players.has(group_key) and music_players[group_key].has(music_key):
		var players = music_players[group_key][music_key]
		if layer_index < players.size():
			for i in range(players.size()):
				players[i].volume_db = 0 if i == layer_index else -80
			_debug_print("Playing layer " + str(layer_index) + " of " + group_key + "/" + music_key)
		else:
			print("Layer index out of range: " + str(layer_index))
	else:
		print("Music not found: " + group_key + "/" + music_key)

func play_from(group_key: String, music_key: String, from: float, to: float = -1):
	if music_players.has(group_key) and music_players[group_key].has(music_key):
		var players = music_players[group_key][music_key]
		for i in range(players.size()):
			players[i].play(from)
			players[i].volume_db = 0 if i == 0 else -80
		if to > from:
			var timer = get_tree().create_timer(to - from)
			timer.connect("timeout", Callable(self, "_on_play_from_timeout").bind(players))
		_debug_print("Music played from " + str(from) + " to " + str(to) + ": " + group_key + "/" + music_key)
	else:
		print("Music not found: " + group_key + "/" + music_key)

func play_varied(group_key: String, music_key: String, volume: float = 0.0, pitch: float = 1.0):
	if music_players.has(group_key) and music_players[group_key].has(music_key):
		var players = music_players[group_key][music_key]
		for i in range(players.size()):
			players[i].volume_db = volume if i == 0 else -80
			players[i].pitch_scale = pitch
			players[i].play()
		_debug_print("Music played with volume " + str(volume) + " and pitch " + str(pitch) + ": " + group_key + "/" + music_key)
	else:
		print("Music not found: " + group_key + "/" + music_key)

func play_from_varied(group_key: String, music_key: String, from: float, to: float = -1, volume: float = 0.0, pitch: float = 1.0):
	if music_players.has(group_key) and music_players[group_key].has(music_key):
		var players = music_players[group_key][music_key]
		for i in range(players.size()):
			players[i].volume_db = volume if i == 0 else -80
			players[i].pitch_scale = pitch
			players[i].play(from)
		if to > from:
			var timer = get_tree().create_timer((to - from) / pitch)
			timer.connect("timeout", Callable(self, "_on_play_from_timeout").bind(players))
		_debug_print("Music played from " + str(from) + " to " + str(to) + " with volume " + str(volume) + " and pitch " + str(pitch) + ": " + group_key + "/" + music_key)
	else:
		print("Music not found: " + group_key + "/" + music_key)

func _on_play_from_timeout(players: Array):
	for player in players:
		player.stop()

func add_layer(group_key: String, music_key: String, layer_index: int):
	if music_players.has(group_key) and music_players[group_key].has(music_key):
		var players = music_players[group_key][music_key]
		if layer_index < players.size():
			players[layer_index].volume_db = 0
			_debug_print("Added layer " + str(layer_index) + " to " + group_key + "/" + music_key)
		else:
			print("Layer index out of range: " + str(layer_index))
	else:
		print("Music not found: " + group_key + "/" + music_key)

func remove_layer(group_key: String, music_key: String, layer_index: int):
	if music_players.has(group_key) and music_players[group_key].has(music_key):
		var players = music_players[group_key][music_key]
		if layer_index < players.size() and layer_index > 0:
			players[layer_index].volume_db = -80
			_debug_print("Removed layer " + str(layer_index) + " from " + group_key + "/" + music_key)
		else:
			print("Invalid layer index: " + str(layer_index))
	else:
		print("Music not found: " + group_key + "/" + music_key)

func stop(group_key: String, music_key: String):
	if music_players.has(group_key) and music_players[group_key].has(music_key):
		var players = music_players[group_key][music_key]
		for player in players:
			player.stop()
		_debug_print("Stopped music: " + group_key + "/" + music_key)
	else:
		print("Music not found: " + group_key + "/" + music_key)

func stop_all():
	_debug_print("Stopping all music")
	for group_key in music_players.keys():
		for music_key in music_players[group_key].keys():
			var players = music_players[group_key][music_key]
			for player in players:
				player.stop()
	_debug_print("All music stopped")

func change_bus_volume(bus_name: String, amount: float):
	var bus_index: int = AudioServer.get_bus_index(bus_name)
	if bus_index != -1:
		var current_volume: float = AudioServer.get_bus_volume_db(bus_index)
		AudioServer.set_bus_volume_db(bus_index, current_volume + amount)
		_debug_print("Changed " + bus_name + " bus volume by " + str(amount) + " dB")
	else:
		print("Bus not found: " + bus_name)

func change_volume(group_key: String, music_key: String, volume: float):
	if music_players.has(group_key) and music_players[group_key].has(music_key):
		var players = music_players[group_key][music_key]
		for player in players:
			player.volume_db = volume
		_debug_print("Changed volume of " + group_key + "/" + music_key + " to " + str(volume) + " dB")
	else:
		print("Music not found: " + group_key + "/" + music_key)

func change_layer_volume(group_key: String, music_key: String, layer_index: int, volume: float):
	if music_players.has(group_key) and music_players[group_key].has(music_key):
		var players = music_players[group_key][music_key]
		if layer_index < players.size():
			players[layer_index].volume_db = volume
			_debug_print("Changed volume of layer " + str(layer_index) + " in " + group_key + "/" + music_key + " to " + str(volume) + " dB")
		else:
			print("Layer index out of range: " + str(layer_index))
	else:
		print("Music not found: " + group_key + "/" + music_key)
#endregion


#region UTILS
func is_playing(group_key: String, music_key: String) -> bool:
	if music_players.has(group_key) and music_players[group_key].has(music_key):
		return music_players[group_key][music_key][0].playing
	else:
		print("Music not found: " + group_key + "/" + music_key)
		return false

func get_active_layers(group_key: String, music_key: String) -> Array[int]:
	var active_layers: Array[int] = []
	if music_players.has(group_key) and music_players[group_key].has(music_key):
		var players = music_players[group_key][music_key]
		for i in range(players.size()):
			if players[i].volume_db > -80:
				active_layers.append(i)
	else:
		print("Music not found: " + group_key + "/" + music_key)
	return active_layers

func _debug_print(message: String):
	if debug_mode:
		print(message)
#endregion
