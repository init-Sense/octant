extends Node

var progress: Array = []
var scene_load_status: int = 0
var current_progress: float = 0.0

@export var progress_sprite: Sprite2D
@export var loading_speed_modifier: float = 1.0  # Higher values make loading slower

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
		
		if scene_load_status != ResourceLoader.THREAD_LOAD_LOADED:
			# Smoothly update the progress
			var target_progress = progress[0] if progress else 0.0
			current_progress = lerp(current_progress, target_progress, delta / loading_speed_modifier)
			
			if progress_sprite:
				progress_sprite.modulate.a = current_progress
		
		if scene_load_status == ResourceLoader.THREAD_LOAD_LOADED:
			if progress_sprite:
				progress_sprite.modulate.a = 1.0
			call_deferred("_change_scene")

func _change_scene():
	var new_scene: PackedScene = ResourceLoader.load_threaded_get(SceneManager.scene_to_load)
	if new_scene:
		# Use change_scene_to_packed to handle scene transition
		get_tree().change_scene_to_packed(new_scene)
	else:
		print("Failed to load new scene!")
	
	SceneManager.scene_to_load = ""
