extends Node

@onready var player: Node3D = $".."

#region SIGNALS
signal movement_changed(state)
signal action_changed(state)
#endregion


#region INPUTS
func _input(event) -> void:
	if event is InputEventMouseButton:
		#region MOVEMENT
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				emit_signal("movement_changed", player.Movement.FORWARD)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				emit_signal("movement_changed", player.Movement.BACKWARD)
		if event.button_index in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT] and event.is_released():
			emit_signal("movement_changed", player.Movement.STILL)
		#endregion
		
		#region JUMP
		if event.button_index == MOUSE_BUTTON_MIDDLE and event.is_released():
			emit_signal("action_changed", player.Action.JUMPING)
		#endregion
#endregion
