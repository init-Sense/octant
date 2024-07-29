extends Node
class_name PlayerJump3D

#region NODES
@onready var player: CharacterBody3D = $"../.."
@onready var movement: PlayerMovement3D = %Movement
#endregion


#region CONSTANTS
const JUMPING_SPEED: float = 10.0
#endregion


#region VARIABLES
var is_jump_requested: bool = false
var is_jumping: bool = false
#endregion


#region LIFECYCLE
func _physics_process(_delta: float) -> void:
	handle_jump()
	ground_check()
#endregion


#region JUMP
func start() -> void:
	if not is_jumping and player.is_on_floor():
		is_jump_requested = true
		player.set_jumping()


func handle_jump() -> void:
	if is_jump_requested and player.is_on_floor():
		movement.velocity_vector.y = JUMPING_SPEED
		is_jumping = true
		is_jump_requested = false


func ground_check() -> void:
	if is_jumping and player.is_on_floor() and movement.velocity_vector.y <= 0:
		is_jumping = false
		player.set_no_action()
#endregion
