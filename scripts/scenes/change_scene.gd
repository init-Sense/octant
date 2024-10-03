extends Area3D
class_name Teleport

#region INSPECTOR
@export_file("*.tscn") var scene_to_load: String
@export var teleport_audio: AudioStream
@export var interrupt_audio: AudioStream
@export var scene_name: String
@export var min_load_time: float = 2.0
#endregion

#region VARIABLES
var audio_player: AudioStreamPlayer
var is_player_inside: bool = false
var scene_load_status: int = 0
var scene_loaded: bool = false
var load_start_time: float = 0.0
#endregion

#region LIFECYCLE
func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	audio_player.finished.connect(_on_audio_finished)

	if SceneManager.previous_scene == scene_name:
		call_deferred("spawn_player_at_arrival")

func _process(delta):
	if scene_to_load and not scene_loaded:
		scene_load_status = ResourceLoader.load_threaded_get_status(scene_to_load)
		
		if scene_load_status == ResourceLoader.THREAD_LOAD_LOADED and Time.get_ticks_msec() - load_start_time >= min_load_time * 1000:
			scene_loaded = true
			_change_scene()
#endregion

#region SIGNALS
func _on_body_entered(body: Node3D):
	if body is Player:
		print("Player entered the area!")
		is_player_inside = true
		if scene_to_load:
			SceneManager.previous_scene = SceneManager.current_scene
			print("Previous scene changed: ", SceneManager.previous_scene)
			SceneManager.scene_to_load = scene_to_load
			if teleport_audio:
				audio_player.stream = teleport_audio
				audio_player.play()
			else:
				_start_scene_load()
		else:
			print("No scene specified to load!")

func _on_body_exited(body: Node3D):
	if body is Player:
		print("Player exited the area!")
		is_player_inside = false
		if audio_player.playing:
			audio_player.stop()
			if interrupt_audio:
				audio_player.stream = interrupt_audio
				audio_player.play()

func _on_audio_finished():
	if is_player_inside and audio_player.stream == teleport_audio:
		_start_scene_load()
#endregion

#region SCENE
func _start_scene_load():
	MusicManager.stop_all()
	ResourceLoader.load_threaded_request(scene_to_load)
	load_start_time = Time.get_ticks_msec()

func _change_scene():
	var new_scene: PackedScene = ResourceLoader.load_threaded_get(scene_to_load)
	if new_scene:
		get_tree().change_scene_to_packed(new_scene)
	else:
		print("Failed to load new scene!")
	
	SceneManager.scene_to_load = ""

func reset_camera():
	print("resetting camera")
	var player: Player = get_tree().get_first_node_in_group("player")
	var camera = player.get_node("Camera")
	camera.fov = player.camera.default_fov

func spawn_player_at_arrival():
	var arrival_node: Node = get_node("Arrival")
	if arrival_node:
		var player: Player = get_tree().get_first_node_in_group("player")

		player.global_position = arrival_node.global_position
		var new_rotation = arrival_node.global_rotation
		new_rotation.y += PI
		player.global_rotation = new_rotation
		print("Player spawned at Arrival node and rotated 180 degrees")
	else:
		print("Arrival node not found!")
#endregion
