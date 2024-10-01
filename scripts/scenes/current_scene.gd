extends Node

@export var scene_name: String
@export var soundtrack: String
@export var soundtrack_volume: float = 0.0

func _ready():
	if soundtrack:
		MusicManager.play_varied(scene_name, soundtrack, soundtrack_volume)
	if scene_name:
		SceneManager.current_scene = scene_name
		print("Current scene set to: ", scene_name)
	else:
		push_warning("No 'scene_name' metadata found on this node.")
