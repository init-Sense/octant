extends Node

@export var scene_name: String

func _ready():
	if scene_name:
		SceneManager.current_scene = scene_name
		print("Current scene set to: ", scene_name)
	else:
		push_warning("No 'scene_name' metadata found on this node.")
