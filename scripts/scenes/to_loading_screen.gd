extends Area3D

@export_file("*.tscn") var scene_to_load: String

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D):
	if body is Player:
		print("Player entered the area!")
		if scene_to_load:
			SceneManager.scene_to_load = scene_to_load
			call_deferred("_change_scene")
		else:
			print("No scene specified to load!")

func _change_scene():
	get_tree().change_scene_to_file("res://scenes/loading_screen/loading_screen.tscn")
