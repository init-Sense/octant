extends Node
class_name PlayerJump

#region NODES
@onready var player: CharacterBody3D = $"../.."
@onready var direction: PlayerDirection = %Direction
@onready var motion: PlayerMotion = %Motion
#endregion

#region CONSTANTS
const JUMPING_SPEED: float = 7.0
const MIDAIR_CONTROL: float = 0.8
const MOMENTUM_FACTOR: float = 0.6
#endregion

#region VARIABLES
var is_jump_requested: bool = false
var jump_momentum: Vector3 = Vector3.ZERO
#endregion

#region SIGNALS
signal jumped
signal landed
#endregion

#region LIFECYCLE
func _physics_process(delta: float) -> void:
	handle_jump()
	apply_midair_control(delta)
	apply_momentum(delta)
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
		jump_momentum = direction.velocity_vector * MOMENTUM_FACTOR
		player.set_jumping()
		is_jump_requested = false

func apply_midair_control(delta: float) -> void:
	if not player.is_on_floor():
		var target_velocity = direction.target_velocity * MIDAIR_CONTROL
		direction.velocity_vector.x = move_toward(direction.velocity_vector.x, target_velocity.x, motion.DECELERATION * delta)
		direction.velocity_vector.z = move_toward(direction.velocity_vector.z, target_velocity.z, motion.DECELERATION * delta)

func apply_momentum(delta: float) -> void:
	if not player.is_on_floor():
		direction.velocity_vector = direction.velocity_vector.lerp(jump_momentum, MOMENTUM_FACTOR * delta)

func ground_check() -> void:
	if player.is_jumping() and player.is_on_floor() and direction.velocity_vector.y <= 0:
		player.set_no_action()
		jump_momentum = Vector3.ZERO
		emit_signal("landed")
#endregion
