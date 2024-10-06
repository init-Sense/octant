extends CanvasLayer


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("move_forward")\
	or Input.is_action_just_pressed("move_backward")\
	or Input.is_action_just_pressed("jump")\
	or Input.is_action_just_pressed("crouch_down")\
	or Input.is_action_just_pressed("crouch_up"):
		get_tree().change_scene_to_file("res://scenes/world_temple.tscn")
