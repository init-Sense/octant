extends Node
class_name Gravity


#region NODES
@onready var player: Player = $"../.."
@onready var movement: Movement = %Movement
#endregion


#region CONSTANTS
const GRAVITY : float = 16.0
#endregion


#region LIFECYCLE
func _physics_process(delta: float) -> void:
	apply_gravity(delta)
#endregion


#region GRAVITY
func apply_gravity(delta) -> void:
	movement.velocity_vector.y -= GRAVITY * delta
	if player.is_on_floor() and movement.velocity_vector.y < 0:
		movement.velocity_vector.y = -0.1
#endregion
