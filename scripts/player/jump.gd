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
const MIN_MOMENTUM_SPEED: float = 0.3
const MAX_MOMENTUM_SPEED: float = 2.0
const MOMENTUM_REDUCTION_FACTOR: float = 0.6
const JUMP_HEIGHT_VARIATION: float = 0.2
const MOMENTUM_VARIATION: float = 0.15
#endregion

#region VARIABLES
var is_jump_requested: bool = false
var jump_momentum: Vector3 = Vector3.ZERO
var horizontal_momentum: Vector2 = Vector2.ZERO
var initial_speed: float = 0.0
var rng = RandomNumberGenerator.new()
#endregion

#region SIGNALS
signal jumped
signal landed
#endregion

#region LIFECYCLE
func _ready() -> void:
	rng.randomize()

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
		horizontal_momentum = Vector2(direction.velocity_vector.x, direction.velocity_vector.z)
		initial_speed = horizontal_momentum.length()
		emit_signal("jumped")

func handle_jump() -> void:
	if is_jump_requested and player.is_on_floor():
		var jump_variation = 1.0 + rng.randf_range(-JUMP_HEIGHT_VARIATION, JUMP_HEIGHT_VARIATION)
		direction.velocity_vector.y = JUMPING_SPEED * jump_variation
		
		var momentum_variation = 1.0 + rng.randf_range(-MOMENTUM_VARIATION, MOMENTUM_VARIATION)
		jump_momentum = direction.velocity_vector * MOMENTUM_FACTOR * momentum_variation
		
		player.set_jumping()
		is_jump_requested = false

func apply_midair_control(delta: float) -> void:
	if not player.is_on_floor():
		var input_dir = get_input_direction()
		var target_velocity: Vector3
		
		if input_dir.length() > 0.1:
			target_velocity = direction.target_velocity * MIDAIR_CONTROL
		else:
			var momentum_speed = clamp(initial_speed, MIN_MOMENTUM_SPEED, MAX_MOMENTUM_SPEED)
			var momentum_factor = inverse_lerp(MIN_MOMENTUM_SPEED, MAX_MOMENTUM_SPEED, momentum_speed)
			var preserved_speed = lerp(MIN_MOMENTUM_SPEED, initial_speed, momentum_factor) * MOMENTUM_REDUCTION_FACTOR
			target_velocity = Vector3(horizontal_momentum.x, 0, horizontal_momentum.y).normalized() * preserved_speed
		
		direction.velocity_vector.x = move_toward(direction.velocity_vector.x, target_velocity.x, motion.DECELERATION * delta)
		direction.velocity_vector.z = move_toward(direction.velocity_vector.z, target_velocity.z, motion.DECELERATION * delta)

func apply_momentum(delta: float) -> void:
	if not player.is_on_floor():
		var reduced_momentum = jump_momentum * MOMENTUM_REDUCTION_FACTOR
		direction.velocity_vector = direction.velocity_vector.lerp(reduced_momentum, MOMENTUM_FACTOR * delta)

func ground_check() -> void:
	if player.is_jumping() and player.is_on_floor() and direction.velocity_vector.y <= 0:
		player.set_no_action()
		jump_momentum = Vector3.ZERO
		horizontal_momentum = Vector2.ZERO
		initial_speed = 0.0
		emit_signal("landed")
#endregion

#region UTILS
func get_input_direction() -> Vector2:
	return Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	).normalized()
#endregion
