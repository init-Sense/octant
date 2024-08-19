extends Node
class_name Jump


#region NODES
@onready var player: Player = $"../.."
@onready var movement: Movement = %Movement
@onready var head: Node3D = %Head
@onready var climb: Climb = %Climb
@onready var crouch: Crouch = %Crouch
#endregion


#region CONSTANTS
const SPEED: float = 8.0
const COYOTE_TIME: float = 0.01
const MOMENTUM_FACTOR: float = 0.6
const MIN_MOMENTUM_SPEED: float = 0.3
const MAX_MOMENTUM_SPEED: float = 2.0
const MOMENTUM_REDUCTION: float = 0.6
const MOMENTUM_VARIATION: float = 0.15
const MIDAIR_CONTROL: float = 0.8
const MAX_CHARGE_TIME: float = 0.5
const MAX_CHARGE_MULTIPLIER: float = 1.7
const HEAD_CHARGE_OFFSET: float = 0.8
const CROUCHED_HEAD_CHARGE_OFFSET: float = 0.2
const VERTICAL_JUMP_FACTOR: float = 0.1
#endregion

#region FREEFALL CONSTANTS
const FREEFALL_INERTIA_REDUCTION_START: float = 0.5
const FREEFALL_INERTIA_REDUCTION_RATE: float = 0.5
#endregion

#region FREEFALL VARIABLES
var freefall_time: float = 0.0
#endregion


#region VARIABLES
var jump_state: Dictionary = {
	is_requested = false,
	momentum = Vector3.ZERO,
	coyote_timer = 0.0,
	can_coyote_jump = false,
	horizontal_momentum = Vector2.ZERO,
	initial_speed = 0.0,
	charge_start_time = 0.0,
	current_charge = 0.0,
	charge_offset = 0.0
}

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
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
	handle_freefall(delta)
	ground_check()
	update_charge_offset(delta)
	update_coyote_time(delta)
#endregion


#region FREEFALL HANDLING
func handle_freefall(delta: float) -> void:
	if not player.is_on_floor() and not climb._snapped_to_stairs_last_frame:
		freefall_time += delta
		if freefall_time > FREEFALL_INERTIA_REDUCTION_START:
			reduce_freefall_inertia(delta)
	else:
		freefall_time = 0.0

func reduce_freefall_inertia(delta: float) -> void:
	var reduction_factor: float = FREEFALL_INERTIA_REDUCTION_RATE * delta
	jump_state.momentum *= (1.0 - reduction_factor)
	jump_state.horizontal_momentum *= (1.0 - reduction_factor)

	var horizontal_velocity: Vector2 = Vector2(movement.velocity_vector.x, movement.velocity_vector.z)
	horizontal_velocity = horizontal_velocity.move_toward(Vector2.ZERO, FREEFALL_INERTIA_REDUCTION_RATE * delta * horizontal_velocity.length())
	movement.velocity_vector.x = horizontal_velocity.x
	movement.velocity_vector.z = horizontal_velocity.y
#endregion


#region JUMP MECHANICS
func start_charge() -> void:
	if (not player.is_jumping() and player.is_on_floor() or climb._snapped_to_stairs_last_frame) or jump_state.can_coyote_jump:
		player.set_charging_jump()
		jump_state.charge_start_time = Time.get_ticks_msec() / 1000.0
		jump_state.current_charge = 0.0

func release_jump() -> void:
	if player.is_charging_jump():
		if (player.is_on_floor() or climb._snapped_to_stairs_last_frame) or jump_state.can_coyote_jump:
			jump_state.is_requested = true
			jump_state.horizontal_momentum = Vector2(movement.velocity_vector.x, movement.velocity_vector.z)
			jump_state.initial_speed = jump_state.horizontal_momentum.length()
			jumped.emit()
			jump_state.can_coyote_jump = false
		else:
			cancel_jump()

func cancel_jump() -> void:
	player.set_no_action()
	jump_state.current_charge = 0.0

func handle_jump() -> void:
	if jump_state.is_requested and ((player.is_on_floor() or climb._snapped_to_stairs_last_frame) or jump_state.can_coyote_jump):
		var charge_multiplier: float = 1.0 + (jump_state.current_charge / MAX_CHARGE_TIME) * (MAX_CHARGE_MULTIPLIER - 1.0)
		var jump_velocity: float = SPEED * charge_multiplier

		var input_dir: Vector2 = get_input_direction()
		var horizontal_velocity: Vector2 = Vector2(movement.velocity_vector.x, movement.velocity_vector.z)
		var input_strength: float = input_dir.length()

		var preserved_horizontal_velocity: Vector2 = horizontal_velocity * MOMENTUM_FACTOR * input_strength
		preserved_horizontal_velocity += input_dir * SPEED * (1 - input_strength)

		preserved_horizontal_velocity *= lerp(VERTICAL_JUMP_FACTOR, 1.0, input_strength)

		movement.velocity_vector.y = jump_velocity
		movement.velocity_vector.x = preserved_horizontal_velocity.x
		movement.velocity_vector.z = preserved_horizontal_velocity.y

		jump_state.momentum = Vector3(movement.velocity_vector.x, 0, movement.velocity_vector.z)

		player.set_jumping()
		jump_state.is_requested = false
		jump_state.current_charge = 0.0
		jump_state.can_coyote_jump = false
#endregion


#region MOVEMENT CONTROL
func apply_midair_control(delta: float) -> void:
	if not player.is_on_floor():
		var input_dir: Vector2 = get_input_direction()
		var target_velocity: Vector3 = Vector3.ZERO

		if input_dir.length() > 0.1:
			target_velocity = movement.target_velocity * MIDAIR_CONTROL
		else:
			var momentum_speed: float = clamp(jump_state.initial_speed, MIN_MOMENTUM_SPEED, MAX_MOMENTUM_SPEED)
			var momentum_factor: float = inverse_lerp(MIN_MOMENTUM_SPEED, MAX_MOMENTUM_SPEED, momentum_speed)
			var preserved_speed: float = lerp(MIN_MOMENTUM_SPEED, jump_state.initial_speed, momentum_factor) * MOMENTUM_REDUCTION
			target_velocity = Vector3(jump_state.horizontal_momentum.x, 0, jump_state.horizontal_momentum.y).normalized() * preserved_speed

		movement.velocity_vector.x = move_toward(movement.velocity_vector.x, target_velocity.x, movement.DECELERATION * delta)
		movement.velocity_vector.z = move_toward(movement.velocity_vector.z, target_velocity.z, movement.DECELERATION * delta)

func apply_momentum(delta: float) -> void:
	if not (player.is_on_floor() or climb._snapped_to_stairs_last_frame):
		var reduced_momentum: Vector3 = jump_state.momentum * MOMENTUM_REDUCTION

		movement.velocity_vector.x = lerp(movement.velocity_vector.x, reduced_momentum.x, MOMENTUM_FACTOR * delta)
		movement.velocity_vector.z = lerp(movement.velocity_vector.z, reduced_momentum.z, MOMENTUM_FACTOR * delta)
#endregion


#region GROUND AND COYOTE TIME
func ground_check() -> void:
	if player.is_on_floor() or climb._snapped_to_stairs_last_frame:
		if player.is_jumping() and movement.velocity_vector.y <= 0:
			player.set_no_action()
			jump_state.momentum = Vector3.ZERO
			jump_state.horizontal_momentum = Vector2.ZERO
			jump_state.initial_speed = 0.0
			jump_state.current_charge = 0.0
			freefall_time = 0.0
			landed.emit()
		jump_state.can_coyote_jump = true
		jump_state.coyote_timer = 0.0
	elif player.is_charging_jump() and not (player.is_on_floor() or climb._snapped_to_stairs_last_frame) and not jump_state.can_coyote_jump:
		cancel_jump()

func update_coyote_time(delta: float) -> void:
	if not (player.is_on_floor() or climb._snapped_to_stairs_last_frame) and jump_state.can_coyote_jump:
		jump_state.coyote_timer += delta
		if jump_state.coyote_timer >= COYOTE_TIME:
			jump_state.can_coyote_jump = false
#endregion


#region VISUAL FEEDBACK
func update_charge_offset(delta: float) -> void:
	var target_offset: float = 0.0
	if player.is_charging_jump():
		jump_state.current_charge = min(jump_state.current_charge + delta, MAX_CHARGE_TIME)
		var charge_progress: float = jump_state.current_charge / MAX_CHARGE_TIME

		var max_offset: float = HEAD_CHARGE_OFFSET if not (player.is_crouched() or player.is_crouching()) else CROUCHED_HEAD_CHARGE_OFFSET
		target_offset = -(charge_progress * max_offset)

	jump_state.charge_offset = move_toward(jump_state.charge_offset, target_offset, delta * 2)

func get_charge_offset() -> float:
	return jump_state.charge_offset
#endregion


#region UTILITY
func get_input_direction() -> Vector2:
	return Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	).normalized()
#endregion
