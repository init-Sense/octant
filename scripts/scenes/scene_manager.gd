extends Node

var scene_to_load: String = ""
var current_scene: String = ""
var previous_scene: String = ""

var sky_visited: bool = false
var forest_visited: bool = false
var frozen_visited: bool = false


func reset_all() -> void:
	scene_to_load = ""
	current_scene = ""
	previous_scene = ""
	
	sky_visited = false
	forest_visited = false
	frozen_visited = false
