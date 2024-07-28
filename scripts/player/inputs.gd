extends Node
class_name PlayerInputsMouse


@onready var player: CharacterBody3D = $"../.."


func _input(event) -> void:
	#region MOVEMENT
	if Input.is_action_just_pressed("move_forward"):
		player.set_movement_forward()
	if Input.is_action_just_pressed("move_backward"):
		player.set_movement_backward()
	if Input.is_action_just_released("move_forward") or Input.is_action_just_released("move_backward"):
		player.set_movement_still()
	#endregion


	#region JUMP
	if Input.is_action_just_released("jump"):
		player.set_action_jumping()
	#endregion


	#region SPRINT
	if Input.is_action_just_pressed("sprint"):
		player.set_action_sprinting()
	elif Input.is_action_just_released("sprint"):
		player.set_action_grounded()
	#endregion
