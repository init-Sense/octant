extends Area3D
class_name Teleport

@export_file("*.tscn") var scene_to_load: String
@export var teleport_audio: AudioStream
@export var interrupt_audio: AudioStream

var audio_player: AudioStreamPlayer
var is_player_inside: bool = false

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	audio_player.finished.connect(_on_audio_finished)

func _on_body_entered(body: Node3D):
	if body is Player:
		print("Player entered the area!")
		is_player_inside = true
		if scene_to_load:
			SceneManager.scene_to_load = scene_to_load
			if teleport_audio:
				audio_player.stream = teleport_audio
				audio_player.play()
			else:
				_change_scene()
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
		_change_scene()

func _change_scene():
	get_tree().change_scene_to_file("res://scenes/loading.tscn")

func reset_camera():
	print("resetting camera")
	# Find the player in the new scene
	var player = get_tree().get_nodes_in_group("player")
	if player.size() > 0:
		player = player[0]
		var camera = player.get_node("Camera")
		# Reset FOV to default
		camera.fov = player.camera.default_fov
	else:
		print("Player not found in the new scene!")
