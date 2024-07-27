extends Node


@onready var player_body: CharacterBody3D = %PlayerBody3D
@onready var player_movement_mouse: PlayerMovementMouse3D = $"../PlayerMovementMouse3D"

const GRAVITY : float = 9.8


#region LIFECYCLE
func _physics_process(delta: float) -> void:
	apply_gravity(delta)
#endregion


#region GRAVITY
func apply_gravity(delta) -> void:
	if not player_body.is_on_floor():
		player_movement_mouse.velocity.y -= GRAVITY * delta
	else:
		player_movement_mouse.velocity.y = -0.1
#endregion
