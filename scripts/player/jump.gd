extends Node
class_name PlayerJump

#region NODES
@onready var player: CharacterBody3D = $"../.."
@onready var direction: PlayerDirection = %Direction
@onready var motion: PlayerMotion = %Motion
#endregion


#region CONSTANTS
const JUMPING_SPEED: float = 7.0
#endregion


#region VARIABLES
var is_jump_requested: bool = false
#endregion


#region SIGNALS
signal jumped
signal landed
#endregion


#region LIFECYCLE
func _physics_process(_delta: float) -> void:
	handle_jump()
	ground_check()
#endregion


#region JUMP
func up() -> void:
	if not player.is_jumping() and player.is_on_floor():
		is_jump_requested = true
		emit_signal("jumped")


func handle_jump() -> void:
	if is_jump_requested and player.is_on_floor():
		direction.velocity_vector.y = JUMPING_SPEED
		player.set_jumping()
		is_jump_requested = false


func ground_check() -> void:
	if player.is_jumping() and player.is_on_floor() and direction.velocity_vector.y <= 0:
		player.set_no_action()
		emit_signal("landed")
#endregion
