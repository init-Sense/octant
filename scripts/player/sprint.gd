extends Node


@onready var player: Player = $"../.."
@onready var movement: PlayerMovement3D = %Movement


const SPRINT_SPEED: float = 7.0


#region LIFECYCLE
#endregion


#region SPRINT
func start() -> void:
	player.set_running()
	movement.current_speed = SPRINT_SPEED


func stop() -> void:
	player.set_walking()
	movement.current_speed = movement.WALKING_SPEED
#endregion
