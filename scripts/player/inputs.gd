extends Node
class_name PlayerInputsMouse


@onready var player: CharacterBody3D = $"../.."


#region INPUTS
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
#endregion
