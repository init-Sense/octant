extends Node
class_name PlayerJump


#region NODES
@onready var player: CharacterBody3D = $"../.."
@onready var direction: PlayerDirection = %Direction
@onready var motion: PlayerMotion = %Motion
@onready var head: Node3D = %Head
#endregion


#region CONSTANTS
#region JUMP CONSTANTS
const JUMPING_SPEED: float = 7.0
const JUMP_HEIGHT_VARIATION: float = 0.2
const COYOTE_TIME: float = 0.15
#endregion


#region MOMENTUM CONSTANTS
const MOMENTUM_FACTOR: float = 0.6
const MIN_MOMENTUM_SPEED: float = 0.3
const MAX_MOMENTUM_SPEED: float = 2.0
const MOMENTUM_REDUCTION_FACTOR: float = 0.6
const MOMENTUM_VARIATION: float = 0.15
#endregion


#region CONTROL CONSTANTS
const MIDAIR_CONTROL: float = 0.8
#endregion


#region CHARGE CONSTANTS
const MAX_CHARGE_TIME: float = 1.0
const MAX_CHARGE_MULTIPLIER: float = 1.5
const HEAD_CHARGE_OFFSET: float = 0.4
#endregion
#endregion


#region VARIABLES
#region JUMP VARIABLES
var is_jump_requested: bool = false
var jump_momentum: Vector3 = Vector3.ZERO
var coyote_timer: float = 0.0
var can_coyote_jump: bool = false
#endregion


#region MOMENTUM VARIABLES
var horizontal_momentum: Vector2 = Vector2.ZERO
var initial_speed: float = 0.0
#endregion


#region CHARGE VARIABLES
var charge_start_time: float = 0.0
var is_charging: bool = false
var current_charge: float = 0.0
#endregion


#region VISUAL VARIABLES
var original_head_position: Vector3
#endregion


#region UTILITY VARIABLES
var rng = RandomNumberGenerator.new()
#endregion
#endregion


#region SIGNALS
signal jumped
signal landed
#endregion


#region LIFECYCLE
func _ready() -> void:
	rng.randomize()
	original_head_position = head.position

func _physics_process(delta: float) -> void:
	handle_jump()
	apply_midair_control(delta)
	apply_momentum(delta)
	ground_check()
	update_head_position(delta)
	update_coyote_time(delta)
#endregion


#region JUMP MECHANICS
func start_charge() -> void:
	if (not player.is_jumping() and player.is_on_floor()) or can_coyote_jump:
		is_charging = true
		charge_start_time = Time.get_ticks_msec() / 1000.0
		current_charge = 0.0

func release_jump() -> void:
	if is_charging:
		if player.is_on_floor() or can_coyote_jump:
			is_jump_requested = true
			horizontal_momentum = Vector2(direction.velocity_vector.x, direction.velocity_vector.z)
			initial_speed = horizontal_momentum.length()
			emit_signal("jumped")
			can_coyote_jump = false
		else:
			cancel_jump()
		is_charging = false

func cancel_jump() -> void:
	is_charging = false
	current_charge = 0.0
	update_head_position(0)

func handle_jump() -> void:
	if is_jump_requested and (player.is_on_floor() or can_coyote_jump):
		var charge_multiplier = 1.0 + (current_charge / MAX_CHARGE_TIME) * (MAX_CHARGE_MULTIPLIER - 1.0)
		
		var jump_variation = 1.0 + rng.randf_range(-JUMP_HEIGHT_VARIATION, JUMP_HEIGHT_VARIATION)
		direction.velocity_vector.y = JUMPING_SPEED * jump_variation * charge_multiplier
		
		var momentum_variation = 1.0 + rng.randf_range(-MOMENTUM_VARIATION, MOMENTUM_VARIATION)
		jump_momentum = direction.velocity_vector * MOMENTUM_FACTOR * momentum_variation
		
		player.set_jumping()
		is_jump_requested = false
		current_charge = 0.0
		can_coyote_jump = false
#endregion


#region MOVEMENT CONTROL
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
	if player.is_on_floor():
		if player.is_jumping() and direction.velocity_vector.y <= 0:
			player.set_no_action()
			jump_momentum = Vector3.ZERO
			horizontal_momentum = Vector2.ZERO
			initial_speed = 0.0
			emit_signal("landed")
		can_coyote_jump = true
		coyote_timer = 0.0
	elif is_charging and not player.is_on_floor() and not can_coyote_jump:
		cancel_jump()

func update_coyote_time(delta: float) -> void:
	if not player.is_on_floor() and can_coyote_jump:
		coyote_timer += delta
		if coyote_timer >= COYOTE_TIME:
			can_coyote_jump = false
#endregion


#region VISUAL FEEDBACK
func update_head_position(delta: float) -> void:
	if is_charging:
		current_charge = min(current_charge + delta, MAX_CHARGE_TIME)
		var charge_progress = current_charge / MAX_CHARGE_TIME
		head.position.y = original_head_position.y - (charge_progress * HEAD_CHARGE_OFFSET)
	else:
		head.position.y = move_toward(head.position.y, original_head_position.y, delta * 2)
#endregion


#region UTILS
func get_input_direction() -> Vector2:
	return Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	).normalized()
#endregion
