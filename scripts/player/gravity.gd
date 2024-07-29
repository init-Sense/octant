extends Node


@onready var player: CharacterBody3D = $"../.."
@onready var movement: PlayerMovement3D = %Movement

const GRAVITY : float = 16


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
