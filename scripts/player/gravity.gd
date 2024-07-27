extends Node


@onready var player: CharacterBody3D = $"../.."
@onready var player_movement: PlayerMovement3D = %Movement

const GRAVITY : float = 9.8


#region LIFECYCLE
func _physics_process(delta: float) -> void:
	apply_gravity(delta)
#endregion


#region GRAVITY
func apply_gravity(delta) -> void:
	if not player.is_on_floor():
		player_movement.velocity.y -= GRAVITY * delta
	else:
		player_movement.velocity.y = -0.1
#endregion
