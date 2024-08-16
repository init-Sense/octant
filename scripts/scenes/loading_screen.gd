extends Node

var progress: Array        = []
var scene_load_status: int = 0
@onready var progress_bar: CSGBox3D = $CSGBox3D

func _ready():
	if SceneManager.scene_to_load:
		ResourceLoader.load_threaded_request(SceneManager.scene_to_load)
	else:
		print("No scene specified to load!")


func _process(_delta):
	if SceneManager.scene_to_load:
		scene_load_status = ResourceLoader.load_threaded_get_status(SceneManager.scene_to_load, progress)
		progress_bar.size.x = floor(progress[0] * 100)
		if scene_load_status == ResourceLoader.THREAD_LOAD_LOADED:
			var new_scene: Resource = ResourceLoader.load_threaded_get(SceneManager.scene_to_load)
			get_tree().change_scene_to_packed(new_scene)
			SceneManager.scene_to_load = ""
