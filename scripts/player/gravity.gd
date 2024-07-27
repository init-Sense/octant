extends Node


@onready var player_body: CharacterBody3D = %PlayerBody
@onready var player_movement: PlayerMovement3D = $"../PlayerMovement"

const GRAVITY : float = 9.8


#region LIFECYCLE
func _physics_process(delta: float) -> void:
	apply_gravity(delta)
#endregion


#region GRAVITY
func apply_gravity(delta) -> void:
	if not player_body.is_on_floor():
		player_movement.velocity.y -= GRAVITY * delta
	else:
		player_movement.velocity.y = -0.1
#endregion
