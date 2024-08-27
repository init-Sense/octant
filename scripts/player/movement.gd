# Movement.gd
# Class: Movement
#
# This script manages the player's movement in various environments, including
# normal surfaces, zero gravity, and slippery surfaces. It handles input
# processing, velocity calculations, and applies appropriate physics based on
# the current environment.
#
# Key Components:
# - Environment Detection: Determines if the player is in zero-g or on a slippery surface
# - Input Handling: Processes player input for movement
# - Velocity Calculation: Computes velocity based on input and environment
# - Movement States: Manages different movement states (idle, walk, run, sneak)
# - Special Environments: Handles zero-g and slippery surface physics
#
# Usage:
# Attach this script to a Node in your player's scene hierarchy. Ensure that
# the required child nodes (Camera, Climb, Crouch, Gravity) are properly set up
# and accessible via the @onready variables.
#
# Environment metadata:
# - Set "zero_g" metadata on the current scene's root node to enable zero-g physics
# - Set "slippery" metadata on the current scene's root node to enable slippery surface physics
# Note: Zero-g takes precedence over slippery if both are set.

extends Node
class_name Movement


#region CONSTANTS
const SPRINT_SPEED: float = 8.0
const WALKING_SPEED: float = 4.0
const SNEAKING_SPEED: float = 1.5
const WALK_DELAY: float = 0.1
const ACCELERATION: float = 30.0
const DECELERATION: float = 15.0
const MOVEMENT_DAMPING: float = 0.01
const MIN_SPEED_FACTOR: float = 0.5
const ZERO_G_DECELERATION: float = 5.0
const SLIPPERY_DECELERATION: float = 1.2
#endregion


#region VARIABLES
var velocity_vector: Vector3 = Vector3.ZERO
var current_speed: float = 0.0
var target_velocity: Vector3 = Vector3.ZERO
var input_dir: Vector3 = Vector3.ZERO
var target_speed: float = 0.0
var is_sprinting: bool = false
var walk_timer: float = 0.0
var is_walk_delayed: bool = false
var is_zero_g: bool = false
var zero_g_momentum: Vector3 = Vector3.ZERO
var slippery: bool = false
var slippery_momentum: Vector3 = Vector3.ZERO
#endregion


#region NODES
@onready var player: Player = $"../.."
@onready var camera: Camera = %Camera
@onready var climb: Climb = %Climb
@onready var crouch: Crouch = %Crouch
@onready var gravity: Gravity = %Gravity
@onready var jump: Jump = %Jump
@onready var area_detector: Area3D = $AreaDetector
#endregion


#region LIFECYCLE
func _ready() -> void:
	area_detector.area_entered.connect(_on_area_entered)
	area_detector.area_exited.connect(_on_area_exited)


func _physics_process(delta: float) -> void:
	update_input_direction()
	update_velocity(delta)
	update_walk_timer(delta)
	apply_movement(delta)
#endregion


#region ENVIRONMENT
func _on_area_entered(area: Area3D) -> void:
	update_environment(area)

func _on_area_exited(_area: Area3D) -> void:
	is_zero_g = false
	slippery = false
	gravity.set_gravity(Gravity.DEFAULT_GRAVITY)

func update_environment(area: Area3D) -> void:
	is_zero_g = area.has_meta("zero_g") and area.get_meta("zero_g")
	slippery = not is_zero_g and area.has_meta("slippery") and area.get_meta("slippery")

	if is_zero_g:
		gravity.set_gravity(0.0)
	else:
		gravity.set_gravity(Gravity.DEFAULT_GRAVITY)

	print("suca")
#endregion


#region MOVEMENT
func apply_movement(delta: float) -> void:
	if not is_zero_g and player.is_on_floor():
		climb._last_frame_was_on_floor = Engine.get_physics_frames()

	if is_zero_g:
		update_zero_g_momentum(delta)
		player.velocity = zero_g_momentum
	elif slippery:
		update_slippery_momentum(delta)
		player.velocity = slippery_momentum
	else:
		player.velocity = velocity_vector

	if not is_zero_g:
		if not climb._snap_up_stairs_check(delta):
			player.move_and_slide()
			climb._snap_down_the_stairs_check()
	else:
		player.move_and_slide()

	reset_vertical_velocity()


func reset_vertical_velocity() -> void:
	if player.is_on_floor():
		if slippery:
			slippery_momentum.y = -0.1
		else:
			velocity_vector.y = -0.1


func update_velocity(delta: float) -> void:
	var speed_modifier: float = calculate_tilt_speed_modifier()
	target_velocity = input_dir * target_speed * speed_modifier

	if is_zero_g or slippery:
		return

	var horizontal_velocity: Vector2 = Vector2(velocity_vector.x, velocity_vector.z)
	var target_horizontal_velocity: Vector2 = Vector2(target_velocity.x, target_velocity.z)

	if input_dir.length() > 0:
		horizontal_velocity = horizontal_velocity.move_toward(target_horizontal_velocity, ACCELERATION * delta)
	else:
		horizontal_velocity = horizontal_velocity.move_toward(Vector2.ZERO, DECELERATION * delta)

	velocity_vector.x = horizontal_velocity.x
	velocity_vector.z = horizontal_velocity.y

	current_speed = velocity_vector.length()


func update_zero_g_momentum(delta: float) -> void:
	if input_dir.length() > 0:
		zero_g_momentum += input_dir * ACCELERATION * delta
	elif zero_g_momentum.length() > 0:
		var deceleration_dir: Vector3 = -zero_g_momentum.normalized()
		var deceleration_amount       = min(ZERO_G_DECELERATION * delta, zero_g_momentum.length())
		zero_g_momentum += deceleration_dir * deceleration_amount

	zero_g_momentum = zero_g_momentum.limit_length(SPRINT_SPEED)


func update_slippery_momentum(delta: float) -> void:
	if input_dir.length() > 0:
		slippery_momentum += input_dir * ACCELERATION * delta
	elif slippery_momentum.length() > 0:
		var deceleration_dir: Vector3 = -slippery_momentum.normalized()
		var deceleration_amount       = min(SLIPPERY_DECELERATION * delta, slippery_momentum.length())
		slippery_momentum += deceleration_dir * deceleration_amount

	slippery_momentum = slippery_momentum.limit_length(SPRINT_SPEED)

	slippery_momentum.y -= gravity.current_gravity * delta

	if player.is_on_floor():
		slippery_momentum = slippery_momentum.slide(player.get_floor_normal())

	if jump.jump_state.is_requested and player.is_on_floor():
		execute_slippery_jump()
#endregion


#region INPUT
func update_input_direction() -> void:
	var input_vector: Vector3 = Vector3.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.z = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")

	if input_vector != Vector3.ZERO:
		var camera_basis: Basis = camera.global_transform.basis
		input_dir = camera_basis * input_vector

		if not is_zero_g:
			input_dir = input_dir.slide(Vector3.UP).normalized()
		else:
			input_dir = input_dir.normalized()

		player.set_forward() if input_vector.z < 0 else player.set_backward()
	else:
		input_dir = Vector3.ZERO
		player.set_still()


func get_direction() -> float:
	var forward_strength: float = Input.get_action_strength("move_forward")
	var backward_strength: float = Input.get_action_strength("move_backward")

	if forward_strength > backward_strength:
		return 1.0
	elif backward_strength > forward_strength:
		return -1.0
	else:
		return 0.0
#endregion


#region MOVEMENT STATES
func idle() -> void:
	player.set_idle()
	target_speed = 0.0
	is_walk_delayed = false


func walk() -> void:
	if not is_walk_delayed:
		is_walk_delayed = true
		walk_timer = 0.0
	elif walk_timer >= WALK_DELAY:
		player.set_walking()
		target_speed = WALKING_SPEED
		is_walk_delayed = false


func run() -> void:
	player.set_running()
	target_speed = SPRINT_SPEED
	is_walk_delayed = false


func sneak() -> void:
	player.set_sneaking()
	update_sneaking_speed()
	is_walk_delayed = false


func update_sneaking_speed() -> void:
	var crouch_percentage: float = crouch.get_crouch_percentage()
	var speed_range: float = WALKING_SPEED - SNEAKING_SPEED
	target_speed = WALKING_SPEED - (speed_range * crouch_percentage)


func update_movement_state() -> void:
	if player.is_still():
		idle()
	elif player.is_crouching() or player.is_crouched():
		sneak()
	elif player.is_running() and not player.is_crouched():
		run()
	else:
		walk()


func start_sprint() -> void:
	player.set_running()
	is_walk_delayed = false
	update_movement_state()


func stop_sprint() -> void:
	update_movement_state()
#endregion


#region UTILS
func calculate_tilt_speed_modifier() -> float:
	if is_zero_g or not player.is_on_floor():
		return 1.0

	var camera_pitch: float = camera.rotation.x
	var pitch_factor = abs(camera_pitch) / (PI / 2)
	var max_slowdown: float = 0.3
	var pitch_threshold: float = 0.3

	if pitch_factor < pitch_threshold:
		return 1.0
	else:
		var slowdown_factor = (pitch_factor - pitch_threshold) / (1 - pitch_threshold)
		return 1.0 - (max_slowdown * slowdown_factor)


func update_walk_timer(delta: float) -> void:
	if is_walk_delayed:
		walk_timer += delta
		if walk_timer >= WALK_DELAY:
			update_movement_state()


func execute_slippery_jump() -> void:
	var charge_multiplier: float = 1.0 + (jump.jump_state.current_charge / jump.MAX_CHARGE_TIME) * (jump.MAX_CHARGE_MULTIPLIER - 1.0)
	var jump_velocity: float = jump.SPEED * charge_multiplier

	var target_vertical_momentum: float = jump_velocity * 3
	slippery_momentum.y = lerp(slippery_momentum.y, target_vertical_momentum, 0.5)

	var horizontal_jump_boost: Vector2 = Vector2(input_dir.x, input_dir.z) * jump_velocity * 0.5
	slippery_momentum.x = lerp(slippery_momentum.x, slippery_momentum.x + horizontal_jump_boost.x, 0.5)
	slippery_momentum.z = lerp(slippery_momentum.z, slippery_momentum.z + horizontal_jump_boost.y, 0.5)

	jump.jump_state.is_requested = false
	jump.jump_state.current_charge = 0.0
	player.set_jumping()
	jump.jumped.emit()
#endregion
