extends Node
class_name PlayerInputsMouse


@onready var player: CharacterBody3D = $"../.."


func _input(event) -> void:
	if event is InputEventMouseButton:
		#region MOVEMENT
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				player.set_movement_forward()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				player.set_movement_backward()
		if event.button_index in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT] and event.is_released():
			player.set_movement_still()
		#endregion
		
		
		#region JUMP
		if event.button_index == MOUSE_BUTTON_MIDDLE and event.is_released():
			player.set_action_jumping()
		#endregion
		
	if Input.is_action_pressed('debug_jump'):
		player.set_action_jumping()

	#region SPRINT
	if event.is_action_pressed("sprint"):
		player.set_action_sprinting()
	elif event.is_action_released("sprint"):
		player.set_action_grounded()
	#endregion
