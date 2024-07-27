extends Node


@onready var player: CharacterBody3D = $"../.."
@onready var camera: PlayerCamera3D = %Camera
@onready var player_movement: PlayerMovement3D = %Movement


#region VARIABLES
const DEFAULT_AMPLITUDE: float = 0.1
const DEFAULT_FREQUENCY: float = 10.0
const AMPLITUDE_FACTOR: float = 0.2
const FREQUENCY_FACTOR: float = 0.4
const RESET_SPEED: float = 1.0
const CAMERA_HEIGHT: float = 0.5

var bob_time: float = 0.0
var current_offset: float = 0.0
var current_amplitude: float = DEFAULT_AMPLITUDE
var current_frequency: float = DEFAULT_FREQUENCY

var is_bobbing: bool = false
#endregion


#region LIFECYCLE
func _physics_process(delta: float) -> void:
	if player.is_moving():
		apply_head_bob(delta)
	elif is_bobbing:
		smooth_reset_head_bob(delta)

	camera.position.y = CAMERA_HEIGHT + current_offset
#endregion


#region HEAD BOB
func apply_head_bob(delta: float) -> void:
	handle_bob_wave()
	bob_time += current_frequency * delta
	current_offset = sin(bob_time) * current_amplitude


func smooth_reset_head_bob(delta: float) -> void:
	current_offset = move_toward(current_offset, 0, RESET_SPEED * delta)

	if abs(current_offset) < 0.01:
		bob_time = 0
		current_offset = 0
		is_bobbing = false


func handle_bob_wave() -> void:
	current_amplitude = DEFAULT_AMPLITUDE * player_movement.velocity.length() * AMPLITUDE_FACTOR
	current_frequency = DEFAULT_FREQUENCY * player_movement.velocity.length() * FREQUENCY_FACTOR
#endregion
