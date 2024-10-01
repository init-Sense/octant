extends Node

var progress: Array = []
var scene_load_status: int = 0
var current_progress: float = 0.0
var scene_loaded: bool = false

@export var progress_sprite: Sprite2D
@export var loading_speed_modifier: float = 1.0
@export var min_load_time: float = 2.0  
@export var max_alpha_increase_per_second: float = 0.1 

var load_time: float = 0.0

func _ready():
	if SceneManager.scene_to_load:
		ResourceLoader.load_threaded_request(SceneManager.scene_to_load)
	else:
		print("No scene specified to load!")
	
	if progress_sprite:
		progress_sprite.modulate.a = 0.0
	else:
		print("Progress sprite not assigned!")

func _process(delta):
	if SceneManager.scene_to_load:
		scene_load_status = ResourceLoader.load_threaded_get_status(SceneManager.scene_to_load, progress)
		
		load_time += delta
		
		if scene_load_status != ResourceLoader.THREAD_LOAD_LOADED:
			var target_progress = progress[0] if progress else 0.0
			var max_progress_increase = max_alpha_increase_per_second * delta
			current_progress = min(current_progress + max_progress_increase, target_progress)
			
			if progress_sprite:
				progress_sprite.modulate.a = current_progress
		
		if scene_load_status == ResourceLoader.THREAD_LOAD_LOADED and load_time >= min_load_time:
			if progress_sprite:
				progress_sprite.modulate.a = 1.0
			scene_loaded = true
	
	if scene_loaded and Input.is_action_just_pressed("move_forward"):
		call_deferred("_change_scene")

func _change_scene():
	var new_scene: PackedScene = ResourceLoader.load_threaded_get(SceneManager.scene_to_load)
	if new_scene:
		get_tree().change_scene_to_packed(new_scene)
	else:
		print("Failed to load new scene!")
	
	SceneManager.scene_to_load = ""
