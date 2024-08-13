extends Node
class_name Gravity


#region NODES
@onready var player: Player = $"../.."
@onready var direction: Movement = %Direction
#endregion


#region CONSTANTS
const GRAVITY : float = 9.8
#endregion


#region LIFECYCLE
func _physics_process(delta: float) -> void:
	apply_gravity(delta)
#endregion


#region GRAVITY
func apply_gravity(delta) -> void:
	direction.velocity_vector.y -= GRAVITY * delta
	if player.is_on_floor() and direction.velocity_vector.y < 0:
		direction.velocity_vector.y = -0.1
#endregion
