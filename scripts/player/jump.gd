extends Node
class_name PlayerJump3D

@onready var player: CharacterBody3D = $"../.."
@onready var movement: PlayerMovement3D = %Movement

const JUMPING_SPEED: float = 10.0
var is_jump_requested: bool = false
var has_jumped: bool = false

#region LIFECYCLE
func _physics_process(_delta: float) -> void:
	handle_jump()
	ground_check()
#endregion

#region JUMP
func start() -> void:
	is_jump_requested = true
	player.set_jumping()

func handle_jump() -> void:
	if is_jump_requested and player.is_on_floor() and not has_jumped:
		movement.velocity_vector.y = JUMPING_SPEED
		has_jumped = true
		is_jump_requested = false
		player.set_no_action()

func ground_check() -> void:
	if has_jumped and player.is_on_floor() and movement.velocity_vector.y <= 0:
		has_jumped = false
#endregion
