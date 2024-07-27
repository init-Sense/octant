extends Node


@onready var player_body: CharacterBody3D = %PlayerBody3D
@onready var player_mouse_movement: PlayerMouseMovement3D = $"../PlayerMouseMovement3D"

const GRAVITY : float = 9.8

func _physics_process(delta: float) -> void:
	apply_gravity(delta)

#region GRAVITY
func apply_gravity(delta) -> void:
	if not player_body.is_on_floor():
		player_mouse_movement.velocity.y -= GRAVITY * delta
	else:
		player_mouse_movement.velocity.y = -0.1
#endregion
