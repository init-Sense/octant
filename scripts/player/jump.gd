extends Node
class_name Jump


#region NODES
@onready var player: Player = $"../.."
@onready var movement: Movement = %Movement
@onready var head: Node3D = %Head
@onready var climb: Climb = %Climb
#endregion


#region CONSTANTS
const JUMP_CONSTANTS = {
	SPEED = 7.0,
	HEIGHT_VARIATION = 0.2,
	COYOTE_TIME = 0.01,
	MOMENTUM_FACTOR = 0.6,
	MIN_MOMENTUM_SPEED = 0.3,
	MAX_MOMENTUM_SPEED = 2.0,
	MOMENTUM_REDUCTION = 0.6,
	MOMENTUM_VARIATION = 0.15,
	MIDAIR_CONTROL = 0.8,
	MAX_CHARGE_TIME = 1.0,
	MAX_CHARGE_MULTIPLIER = 1.5,
	HEAD_CHARGE_OFFSET = 0.4
}
#endregion


#region VARIABLES
var jump_state = {
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
	ground_check()
	update_charge_offset(delta)
	update_coyote_time(delta)
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
		var charge_multiplier: float = 1.0 + (jump_state.current_charge / JUMP_CONSTANTS.MAX_CHARGE_TIME) * (JUMP_CONSTANTS.MAX_CHARGE_MULTIPLIER - 1.0)
		var jump_variation: float = 1.0 + rng.randf_range(-JUMP_CONSTANTS.HEIGHT_VARIATION, JUMP_CONSTANTS.HEIGHT_VARIATION)
		movement.velocity_vector.y = JUMP_CONSTANTS.SPEED * jump_variation * charge_multiplier
		
		var momentum_variation: float = 1.0 + rng.randf_range(-JUMP_CONSTANTS.MOMENTUM_VARIATION, JUMP_CONSTANTS.MOMENTUM_VARIATION)
		jump_state.momentum = movement.velocity_vector * JUMP_CONSTANTS.MOMENTUM_FACTOR * momentum_variation
		
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
			target_velocity = movement.target_velocity * JUMP_CONSTANTS.MIDAIR_CONTROL
		else:
			var momentum_speed: float = clamp(jump_state.initial_speed, JUMP_CONSTANTS.MIN_MOMENTUM_SPEED, JUMP_CONSTANTS.MAX_MOMENTUM_SPEED)
			var momentum_factor: float = inverse_lerp(JUMP_CONSTANTS.MIN_MOMENTUM_SPEED, JUMP_CONSTANTS.MAX_MOMENTUM_SPEED, momentum_speed)
			var preserved_speed: float = lerp(JUMP_CONSTANTS.MIN_MOMENTUM_SPEED, jump_state.initial_speed, momentum_factor) * JUMP_CONSTANTS.MOMENTUM_REDUCTION
			target_velocity = Vector3(jump_state.horizontal_momentum.x, 0, jump_state.horizontal_momentum.y).normalized() * preserved_speed
		
		movement.velocity_vector.x = move_toward(movement.velocity_vector.x, target_velocity.x, movement.DECELERATION * delta)
		movement.velocity_vector.z = move_toward(movement.velocity_vector.z, target_velocity.z, movement.DECELERATION * delta)

func apply_momentum(delta: float) -> void:
	if not (player.is_on_floor() or climb._snapped_to_stairs_last_frame):
		var reduced_momentum: Vector3 = jump_state.momentum * JUMP_CONSTANTS.MOMENTUM_REDUCTION
		movement.velocity_vector = movement.velocity_vector.lerp(reduced_momentum, JUMP_CONSTANTS.MOMENTUM_FACTOR * delta)
#endregion


#region GROUND AND COYOTE TIME
func ground_check() -> void:
	if player.is_on_floor() or climb._snapped_to_stairs_last_frame:
		if player.is_jumping() and movement.velocity_vector.y <= 0:
			player.set_no_action()
			jump_state.momentum = Vector3.ZERO
			jump_state.horizontal_momentum = Vector2.ZERO
			jump_state.initial_speed = 0.0
			landed.emit()
		jump_state.can_coyote_jump = true
		jump_state.coyote_timer = 0.0
	elif player.is_charging_jump() and not (player.is_on_floor() or climb._snapped_to_stairs_last_frame) and not jump_state.can_coyote_jump:
		cancel_jump()

func update_coyote_time(delta: float) -> void:
	if not (player.is_on_floor() or climb._snapped_to_stairs_last_frame) and jump_state.can_coyote_jump:
		jump_state.coyote_timer += delta
		if jump_state.coyote_timer >= JUMP_CONSTANTS.COYOTE_TIME:
			jump_state.can_coyote_jump = false
#endregion


#region VISUAL FEEDBACK
func update_charge_offset(delta: float) -> void:
	var target_offset: float = 0.0
	if player.is_charging_jump():
		jump_state.current_charge = min(jump_state.current_charge + delta, JUMP_CONSTANTS.MAX_CHARGE_TIME)
		var charge_progress: float = jump_state.current_charge / JUMP_CONSTANTS.MAX_CHARGE_TIME
		target_offset = -(charge_progress * JUMP_CONSTANTS.HEAD_CHARGE_OFFSET)
	
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
