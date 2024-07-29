extends Node


#region NODES
@onready var player: CharacterBody3D = $"../.."
@onready var direction: PlayerMovement3D = %Direction
#endregion


#region CONSTANTS
const GRAVITY : float = 16
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
