# HeadBob.gd
# Class: HeadBob
#
# This script manages various camera effects to simulate realistic head movement:
# - Head bobbing during movement
# - Landing impact when the player touches the ground after a jump
# - Idle movement when the player is stationary
# - Fall bobbing effect when the player is in freefall
#
# The script uses sine waves and noise to create natural-looking movements,
# and smoothly transitions between different states.
#
# Key Components:
# - Head Bob: Simulates the up-and-down movement while walking or running
# - Landing Impact: Creates a visual impact effect when landing from a jump
# - Idle Movement: Adds subtle movement to the camera when the player is still
# - Fall Bob: Simulates camera shake during freefall
#
# Usage:
# Attach this script to a Node in your player's scene hierarchy. Ensure that
# the required child nodes (Camera, Movement, Jump, Gravity) are properly set up
# and accessible via the @onready variables.

extends Node
class_name HeadBob


#region NODES
@onready var player: Player = $"../.."
@onready var camera: Camera = %Camera
@onready var movement: Movement = %Movement
@onready var jump: Jump = %Jump
@onready var gravity: Gravity = %Gravity
#endregion


#region CONSTANTS
const DEFAULT_AMPLITUDE: float = 0.05
const DEFAULT_FREQUENCY: float = 5.0
const AMPLITUDE_FACTOR: float = 0.15
const FREQUENCY_FACTOR: float = 0.4
const RESET_SPEED: float = 1.0
const CAMERA_HEIGHT: float = 0.5
const X_FACTOR: float = 0.6
const NOISE_STRENGTH: float = 0.03

const BASE_LANDING_IMPACT_AMPLITUDE: float = 0.05
const MAX_LANDING_IMPACT_AMPLITUDE: float = 0.15
const LANDING_IMPACT_DURATION: float = 0.2
const LANDING_RESET_SPEED: float = 2.0
const MAX_IMPACT_HEIGHT: float = 10.0

const IDLE_AMPLITUDE: float = 0.02
const IDLE_FREQUENCY: float = 0.4
const IDLE_NOISE_STRENGTH: float = 0.15

const FALL_BOB_MAX_AMPLITUDE: float = 0.3
const FALL_BOB_FREQUENCY: float = 15.0
const FALL_BOB_VELOCITY_THRESHOLD: float = 40.0
const FALL_DURATION_THRESHOLD: float = 2.0
const MAX_FALL_SHAKE_FACTOR: float = 10.0 
#endregion


#region VARIABLES
# Head Bob Variables
var bob_time: float = 0.0
var current_offset: Vector3 = Vector3.ZERO
var current_amplitude: float = DEFAULT_AMPLITUDE
var current_frequency: float = DEFAULT_FREQUENCY
var is_bobbing: bool = false

# Landing Variables
var landing_impact_time: float = 0.0
var is_landing: bool = false
var landing_offset: float = 0.0
var max_jump_height: float = 0.0
var jump_start_height: float = 0.0
var current_landing_impact_amplitude: float = BASE_LANDING_IMPACT_AMPLITUDE

# Idle Movement Variables
var idle_time: float = 0.0
var idle_offset: Vector3 = Vector3.ZERO

# Fall Bob Variables
var fall_bob_time: float = 0.0
var fall_bob_offset: Vector3 = Vector3.ZERO
var fall_duration: float = 0.0

# Noise Generator
var noise: FastNoiseLite = FastNoiseLite.new()
#endregion


#region LIFECYCLE METHODS
func _ready() -> void:
	jump.connect("jumped", Callable(self, "on_player_jumped"))
	jump.connect("landed", Callable(self, "on_player_landed"))
	noise.seed = randi()


func _physics_process(delta: float) -> void:
	if player.is_on_floor():
		fall_duration = 0.0
		if player.has_direction() and not player.is_jumping():
			handle_head_bob(delta)
		elif is_bobbing:
			smooth_reset_head_bob(delta)
		else:
			apply_idle_movement(delta)
	else:
		fall_duration += delta
		handle_fall_bob(delta)

	handle_landing(delta)
	update_camera_position()
#endregion


#region HEAD BOB METHODS
func handle_head_bob(delta: float) -> void:
	apply_head_bob(delta)


func apply_head_bob(delta: float) -> void:
	handle_bob_wave()
	bob_time += current_frequency * delta
	var y_offset: float = sin(bob_time) * current_amplitude
	var x_offset: float = cos(bob_time * 0.5) * current_amplitude * X_FACTOR

	y_offset += noise.get_noise_1d(bob_time * 10) * NOISE_STRENGTH
	x_offset += noise.get_noise_1d(bob_time * 10 + 100) * NOISE_STRENGTH

	current_offset = Vector3(x_offset, y_offset, 0)
	is_bobbing = true


func smooth_reset_head_bob(delta: float) -> void:
	current_offset = current_offset.move_toward(Vector3.ZERO, RESET_SPEED * delta)
	if current_offset.length() < 0.001:
		bob_time = 0
		current_offset = Vector3.ZERO
		is_bobbing = false


func handle_bob_wave() -> void:
	var speed: float = movement.velocity_vector.length()
	current_amplitude = DEFAULT_AMPLITUDE * speed * AMPLITUDE_FACTOR
	current_frequency = DEFAULT_FREQUENCY * speed * FREQUENCY_FACTOR
#endregion


#region LANDING METHODS
func handle_landing(delta: float) -> void:
	if player.is_jumping():
		track_jump_height()

	if is_landing:
		apply_landing_impact(delta)
	elif landing_offset != 0:
		smooth_reset_landing_impact(delta)


func on_player_jumped() -> void:
	jump_start_height = player.global_position.y
	max_jump_height = jump_start_height


func track_jump_height() -> void:
	max_jump_height = max(max_jump_height, player.global_position.y)


func on_player_landed() -> void:
	is_landing = true
	landing_impact_time = 0.0
	var jump_height: float = max_jump_height - jump_start_height
	var height_factor = clamp(jump_height / MAX_IMPACT_HEIGHT, 0, 1)
	current_landing_impact_amplitude = lerp(BASE_LANDING_IMPACT_AMPLITUDE, MAX_LANDING_IMPACT_AMPLITUDE, height_factor)


func apply_landing_impact(delta: float) -> void:
	landing_impact_time += delta
	var impact_progress: float = landing_impact_time / LANDING_IMPACT_DURATION
	landing_offset = -sin(impact_progress * PI) * current_landing_impact_amplitude

	if landing_impact_time >= LANDING_IMPACT_DURATION:
		is_landing = false


func smooth_reset_landing_impact(delta: float) -> void:
	landing_offset = move_toward(landing_offset, 0, LANDING_RESET_SPEED * delta)
#endregion


#region IDLE MOVEMENT METHODS
func apply_idle_movement(delta: float) -> void:
	idle_time += delta

	var base_y_offset: float = sin(idle_time * IDLE_FREQUENCY) * IDLE_AMPLITUDE
	var base_x_offset: float = cos(idle_time * IDLE_FREQUENCY * 0.7) * IDLE_AMPLITUDE * 0.5

	var noise_x: float = noise.get_noise_1d(idle_time * 5) * IDLE_NOISE_STRENGTH
	var noise_y: float = noise.get_noise_1d(idle_time * 5 + 100) * IDLE_NOISE_STRENGTH

	idle_offset = Vector3(base_x_offset + noise_x, base_y_offset + noise_y, 0)
#endregion


#region FALL BOB METHODS
func handle_fall_bob(delta: float) -> void:
	var fall_speed = abs(movement.velocity_vector.y)
	if fall_speed > abs(gravity.TERMINAL_VELOCITY):
		apply_fall_bob(delta, fall_speed)
	else:
		smooth_reset_fall_bob(delta)

func apply_fall_bob(delta: float, fall_speed: float) -> void:
	fall_bob_time += FALL_BOB_FREQUENCY * delta
	var speed_factor = clamp((fall_speed - abs(gravity.TERMINAL_VELOCITY)) / (gravity.TERMINAL_VELOCITY - abs(gravity.TERMINAL_VELOCITY)), 0, 1)
	
	var shake_factor = 1.0
	if fall_duration > FALL_DURATION_THRESHOLD:
		shake_factor = min(1.0 + (fall_duration - FALL_DURATION_THRESHOLD), MAX_FALL_SHAKE_FACTOR)
	
	var amplitude = FALL_BOB_MAX_AMPLITUDE * speed_factor * shake_factor

	var x_offset = cos(fall_bob_time * 0.7) * amplitude
	var y_offset = sin(fall_bob_time) * amplitude

	var noise_strength = NOISE_STRENGTH * shake_factor
	x_offset += noise.get_noise_1d(fall_bob_time * 15) * noise_strength * speed_factor
	y_offset += noise.get_noise_1d(fall_bob_time * 15 + 100) * noise_strength * speed_factor

	fall_bob_offset = Vector3(x_offset, y_offset, 0)


func smooth_reset_fall_bob(delta: float) -> void:
	fall_bob_offset = fall_bob_offset.move_toward(Vector3.ZERO, RESET_SPEED * delta)
	if fall_bob_offset.length() < 0.001:
		fall_bob_time = 0
		fall_bob_offset = Vector3.ZERO
#endregion


#region CAMERA UPDATE
func update_camera_position() -> void:
	var total_offset: Vector3 = current_offset + idle_offset + fall_bob_offset
	camera.position = Vector3(total_offset.x, CAMERA_HEIGHT + total_offset.y + landing_offset, total_offset.z)
#endregion
