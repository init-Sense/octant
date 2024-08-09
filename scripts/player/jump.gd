extends Node
class_name PlayerJump


#region NODES
@onready var player: CharacterBody3D = $"../.."
@onready var direction: PlayerDirection = %Direction
@onready var motion: PlayerMotion = %Motion
@onready var head: StaticBody3D = %Head
#endregion


#region CONSTANTS
#region JUMP CONSTANTS
const BASE_JUMPING_SPEED: float = 7.0
const JUMP_HEIGHT_VARIATION: float = 0.2
#endregion

#region CHARGE CONSTANTS
const MAX_CHARGE_TIME: float = 1.0
const MAX_CHARGE_MULTIPLIER: float = 1.5
const HEAD_CHARGE_MOVEMENT: float = 0.1
#endregion

#region MOMENTUM CONSTANTS
const MIDAIR_CONTROL: float = 0.8
const MOMENTUM_FACTOR: float = 0.6
const MIN_MOMENTUM_SPEED: float = 0.3
const MAX_MOMENTUM_SPEED: float = 2.0
const MOMENTUM_REDUCTION_FACTOR: float = 0.4
const MOMENTUM_VARIATION: float = 0.15
#endregion
#endregion


#region VARIABLES
#region JUMP VARIABLES
var is_jump_requested: bool = false
var initial_speed: float = 0.0
#endregion

#region CHARGE VARIABLES
var charge_time: float = 0.0
var is_charging: bool = false
#endregion

#region MOMENTUM VARIABLES
var jump_momentum: Vector3 = Vector3.ZERO
var horizontal_momentum: Vector2 = Vector2.ZERO
#endregion

#region UTILITY VARIABLES
var rng = RandomNumberGenerator.new()
var initial_head_position: Vector3
#endregion
#endregion


#region SIGNALS
signal jumped
signal landed
signal charge_updated(progress: float)
#endregion


#region LIFECYCLE
func _ready() -> void:
	rng.randomize()
	initial_head_position = head.position


func _physics_process(delta: float) -> void:
	handle_jump()
	apply_midair_control(delta)
	apply_momentum(delta)
	ground_check()
	update_charge(delta)
#endregion


#region JUMP MECHANICS
func up() -> void:
	if not player.is_jumping() and player.is_on_floor():
		is_jump_requested = true
		horizontal_momentum = Vector2(direction.velocity_vector.x, direction.velocity_vector.z)
		initial_speed = horizontal_momentum.length()
		emit_signal("jumped")

func handle_jump() -> void:
	if is_jump_requested and player.is_on_floor():
		var charge_multiplier = lerp(1.0, MAX_CHARGE_MULTIPLIER, charge_time / MAX_CHARGE_TIME)
		var jump_variation = 1.0 + rng.randf_range(-JUMP_HEIGHT_VARIATION, JUMP_HEIGHT_VARIATION)
		var jumping_speed = BASE_JUMPING_SPEED * charge_multiplier * jump_variation
		
		direction.velocity_vector.y = jumping_speed
		
		var momentum_variation = 1.0 + rng.randf_range(-MOMENTUM_VARIATION, MOMENTUM_VARIATION)
		jump_momentum = direction.velocity_vector * MOMENTUM_FACTOR * momentum_variation
		
		player.set_jumping()
		is_jump_requested = false
		charge_time = 0.0
		reset_head_position()
#endregion


#region CHARGE MECHANICS
func start_charge() -> void:
	if player.is_on_floor() and not is_charging:
		is_charging = true
		charge_time = 0.0

func release_charge() -> void:
	if is_charging:
		is_jump_requested = true
		is_charging = false
		reset_head_position()

func update_charge(delta: float) -> void:
	if is_charging:
		charge_time = min(charge_time + delta, MAX_CHARGE_TIME)
		var charge_progress = charge_time / MAX_CHARGE_TIME
		emit_signal("charge_updated", charge_progress)
		update_head_position(charge_progress)
#endregion


#region HEAD MOVEMENT
func update_head_position(charge_progress: float) -> void:
	var new_y = initial_head_position.y - (HEAD_CHARGE_MOVEMENT * charge_progress)
	head.position.y = new_y

func reset_head_position() -> void:
	head.position.y = initial_head_position.y
#endregion


#region MOMENTUM AND MIDAIR CONTROL
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
#endregion


#region GROUND CHECK
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
