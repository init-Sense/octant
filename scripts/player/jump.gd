extends Node
class_name PlayerJump3D

@onready var player: CharacterBody3D = $"../.."
@onready var movement: PlayerMovement3D = %Movement

const JUMPING_SPEED: float = 10.0
var has_jumped: bool = false


#region LIFECYCLE
func _physics_process(_delta: float) -> void:
	handle_jump()
	ground_check()
#endregion


#region JUMP
func handle_jump() -> void:
	if player.is_jumping() and player.is_on_floor() and not has_jumped:
		movement.velocity_vector.y = JUMPING_SPEED
		has_jumped = true


func ground_check() -> void:
	if has_jumped and player.is_on_floor() and movement.velocity_vector.y <= 0:
		has_jumped = false
		player.set_action_grounded()
#endregion
