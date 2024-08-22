extends Node
class_name Gravity

#region NODES
@onready var player: Player = $"../.."
@onready var movement: Movement = %Movement
#endregion

#region CONSTANTS
const DEFAULT_GRAVITY: float = 16.0
const TERMINAL_VELOCITY: float = -40.0
#endregion

#region VARIABLES
var current_gravity: float = DEFAULT_GRAVITY
#endregion

#region LIFECYCLE
func _physics_process(delta: float) -> void:
	apply_gravity(delta)
#endregion

#region GRAVITY
func apply_gravity(delta) -> void:
	movement.velocity_vector.y -= current_gravity * delta
	movement.velocity_vector.y = max(movement.velocity_vector.y, TERMINAL_VELOCITY)
	if player.is_on_floor() and movement.velocity_vector.y < 0:
		movement.velocity_vector.y = -0.1

func set_gravity(new_gravity: float) -> void:
	current_gravity = new_gravity
#endregion
