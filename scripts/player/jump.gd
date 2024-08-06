extends Node
class_name PlayerJump3D


#region NODES
@onready var player: CharacterBody3D = $"../.."
@onready var direction: PlayerMovement3D = %Direction
@onready var motion: Node = %Motion
#endregion


#region CONSTANTS
const JUMPING_SPEED: float = 10.0
const MIN_INERTIA_FACTOR: float = 0.6
const MAX_INERTIA_FACTOR: float = 0.9
const INERTIA_DECELERATION: float = 2.0
#endregion


#region VARIABLES
var is_jump_requested: bool = false
var jump_inertia: Vector2 = Vector2.ZERO
#endregion


#region SIGNALS
signal landed
#endregion


#region LIFECYCLE
func _physics_process(delta: float) -> void:
	handle_jump()
	apply_inertia(delta)
	ground_check()
#endregion


#region JUMP
func up() -> void:
	if not player.is_jumping() and player.is_on_floor():
		is_jump_requested = true

		var current_speed = direction.current_speed
		var speed_range = motion.SPRINT_SPEED - motion.SNEAKING_SPEED
		var speed_factor = (current_speed - motion.SNEAKING_SPEED) / speed_range
		var inertia_factor = lerp(MIN_INERTIA_FACTOR, MAX_INERTIA_FACTOR, speed_factor)
		
		jump_inertia = Vector2(direction.velocity_vector.x, direction.velocity_vector.z) * inertia_factor


func handle_jump() -> void:
	if is_jump_requested and player.is_on_floor():
		direction.velocity_vector.y = JUMPING_SPEED
		player.set_jumping()
		is_jump_requested = false


func apply_inertia(delta: float) -> void:
	if player.is_jumping():
		direction.velocity_vector.x = jump_inertia.x
		direction.velocity_vector.z = jump_inertia.y
		
		jump_inertia = jump_inertia.move_toward(Vector2.ZERO, INERTIA_DECELERATION * delta)


func ground_check() -> void:
	if player.is_jumping() and player.is_on_floor() and direction.velocity_vector.y <= 0:
		player.set_no_action()
		jump_inertia = Vector2.ZERO
		emit_signal("landed")
#endregion
