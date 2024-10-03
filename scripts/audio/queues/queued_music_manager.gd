extends Node

#region INSPECTOR
@export var debug_mode: bool = false
@export var groups: Array[QueuedMusicGroup]
@export var fade_out_duration: float = 5.0
#endregion


#region VARIABLES
var music_players: Dictionary = {}
var current_group_key: String = ""
var current_track_index: int = -1
var current_stem_index: int = -1
var is_playing: bool = false
var should_terminate: bool = false
var should_terminate_stem: bool = false
var fade_tween: Tween = null
#endregion


#region LIFECYCLE
func _ready():
	_initialize_music_players()

func _initialize_music_players():
	_debug_print("Initializing QueuedMusicManager...")
	music_players.clear()
	for group in groups:
		music_players[group.key] = {}
		for track in group.tracks:
			_debug_print("Processing track: %s in group: %s" % [track.key, group.key])
			music_players[group.key][track.key] = []
			for stem in track.stems:
				var player = AudioStreamPlayer.new()
				player.stream = stem
				player.bus = group.bus
				player.volume_db = -80
				add_child(player)
				music_players[group.key][track.key].append(player)
			track.duration = track.stems[0].get_length()
	_debug_print("QueuedMusicManager initialization complete. Total groups: %d" % groups.size())

func _process(delta):
	if is_playing:
		var current_group = _find_group(current_group_key)
		if current_group and current_track_index >= 0 and current_track_index < current_group.tracks.size():
			var current_track = current_group.tracks[current_track_index]
			if not music_players[current_group_key][current_track.key][current_stem_index].playing and not fade_tween:
				if should_terminate:
					play_next(false)
				else:
					advance_stem()
#endregion


#region QUEUE CONTROLS
func start_playback(group_key: String, track_key: String):
	var group = _find_group(group_key)
	if group:
		current_group_key = group_key
		current_track_index = _find_track_index(group, track_key)
		if current_track_index != -1:
			current_stem_index = 0
			play_current_stem()
		else:
			_debug_print("Track %s not found in group %s" % [track_key, group_key])
	else:
		_debug_print("Group %s not found" % group_key)

func play_next(terminate: bool = false):
	should_terminate = terminate
	var current_group = _find_group(current_group_key)
	if current_group and current_track_index < current_group.tracks.size() - 1:
		if not terminate:
			stop_current()
			current_track_index += 1
			current_stem_index = 0
			play_current_stem()
	else:
		_debug_print("End of queue reached")
		stop_all()

func play_previous():
	if current_track_index > 0:
		stop_current()
		current_track_index -= 1
		current_stem_index = 0
		play_current_stem()
	else:
		_debug_print("Already at the beginning of the queue")

func play_next_part(terminate: bool = false):
	should_terminate_stem = terminate
	if terminate:
		fade_out_current_stem()
	else:
		advance_stem()
		
func advance_stem():
	var current_group = _find_group(current_group_key)
	if current_group and current_track_index >= 0 and current_track_index < current_group.tracks.size():
		var current_track = current_group.tracks[current_track_index]
		if current_stem_index < current_track.stems.size() - 1:
			stop_current_stem()
			current_stem_index += 1
			play_current_stem()
		else:
			_debug_print("End of stems reached for current track")
			should_terminate_stem = false
			play_next(true)

func fade_out_current_stem():
	var current_group = _find_group(current_group_key)
	if current_group and current_track_index >= 0 and current_track_index < current_group.tracks.size():
		var current_track = current_group.tracks[current_track_index]
		if current_stem_index >= 0 and current_stem_index < current_track.stems.size():
			var current_player = music_players[current_group_key][current_track.key][current_stem_index]
			
			if fade_tween:
				fade_tween.kill()
			
			fade_tween = create_tween()
			fade_tween.tween_property(current_player, "volume_db", -80.0, fade_out_duration)
			fade_tween.tween_callback(func():
				stop_current_stem()
				advance_stem()
				fade_tween = null
			)

func play_previous_part():
	if current_stem_index > 0:
		stop_current_stem()
		current_stem_index -= 1
		play_current_stem()
	else:
		_debug_print("Already at the beginning of stems for current track")

func pause():
	if is_playing:
		var current_group = _find_group(current_group_key)
		if current_group and current_track_index >= 0 and current_track_index < current_group.tracks.size():
			var current_track = current_group.tracks[current_track_index]
			music_players[current_group_key][current_track.key][current_stem_index].stream_paused = true
			is_playing = false
			_debug_print("Playback paused")

func resume():
	if not is_playing and current_track_index >= 0:
		var current_group = _find_group(current_group_key)
		if current_group and current_track_index < current_group.tracks.size():
			var current_track = current_group.tracks[current_track_index]
			music_players[current_group_key][current_track.key][current_stem_index].stream_paused = false
			is_playing = true
			_debug_print("Playback resumed")

func stop_all():
	if fade_tween:
		fade_tween.kill()
		fade_tween = null
	
	for group_key in music_players.keys():
		for track_key in music_players[group_key].keys():
			for player in music_players[group_key][track_key]:
				player.stop()
	is_playing = false
	current_track_index = -1
	current_stem_index = -1
	current_group_key = ""
	should_terminate = false
	should_terminate_stem = false
	_debug_print("All playback stopped")

func play_current_stem():
	var current_group = _find_group(current_group_key)
	if current_group and current_track_index >= 0 and current_track_index < current_group.tracks.size():
		var current_track = current_group.tracks[current_track_index]
		if current_stem_index >= 0 and current_stem_index < current_track.stems.size():
			stop_current_stem()
			var current_player = music_players[current_group_key][current_track.key][current_stem_index]
			current_player.volume_db = 0
			current_player.play()
			is_playing = true
			_debug_print("Now playing: %s/%s - Stem %d" % [current_group_key, current_track.key, current_stem_index])
		else:
			_debug_print("Invalid stem index")
			should_terminate_stem = false
			play_next(true)
	else:
		_debug_print("No track to play")

func stop_current_stem():
	if fade_tween:
		fade_tween.kill()
		fade_tween = null
	
	var current_group = _find_group(current_group_key)
	if current_group and current_track_index >= 0 and current_track_index < current_group.tracks.size():
		var current_track = current_group.tracks[current_track_index]
		for i in range(current_track.stems.size()):
			music_players[current_group_key][current_track.key][i].stop()
			music_players[current_group_key][current_track.key][i].volume_db = -80
		_debug_print("Stopped current stem")

func stop_current():
	stop_current_stem()
	current_stem_index = -1
#endregion


#region UTILS
func _debug_print(message: String):
	if debug_mode:
		print(message)

func _find_group(group_key: String) -> QueuedMusicGroup:
	for group in groups:
		if group.key == group_key:
			return group
	return null

func _find_track_index(group: QueuedMusicGroup, track_key: String) -> int:
	for i in range(group.tracks.size()):
		if group.tracks[i].key == track_key:
			return i
	return -1
#endregion
