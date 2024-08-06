extends Node

#region NODES
@onready var player: CharacterBody3D = $"../.."
@onready var camera: PlayerCamera3D = %Camera
@onready var direction: PlayerMovement3D = %Direction
@onready var jump: PlayerJump3D = %Jump
#endregion


#region VARIABLES
const DEFAULT_AMPLITUDE: float = 0.1
const DEFAULT_FREQUENCY: float = 5.0
const AMPLITUDE_FACTOR: float = 0.2
const FREQUENCY_FACTOR: float = 0.4
const RESET_SPEED: float = 1.0
const CAMERA_HEIGHT: float = 0.5
const BASE_LANDING_IMPACT_AMPLITUDE: float = 0.05
const MAX_LANDING_IMPACT_AMPLITUDE: float = 0.15
const LANDING_IMPACT_DURATION: float = 0.2
const LANDING_RESET_SPEED: float = 2.0
const MAX_IMPACT_HEIGHT: float = 10.0


var bob_time: float = 0.0
var current_offset: float = 0.0
var current_amplitude: float = DEFAULT_AMPLITUDE
var current_frequency: float = DEFAULT_FREQUENCY
var is_bobbing: bool = false
var landing_impact_time: float = 0.0
var is_landing: bool = false
var landing_offset: float = 0.0
var max_jump_height: float = 0.0
var jump_start_height: float = 0.0
var current_landing_impact_amplitude: float = BASE_LANDING_IMPACT_AMPLITUDE
#endregion


#region LIFECYCLE
func _physics_process(delta: float) -> void:
	if player.is_moving() and not player.is_jumping():
		apply_head_bob(delta)
	elif is_bobbing:
		smooth_reset_head_bob(delta)
	
	if player.is_jumping():
		track_jump_height()
	
	if is_landing:
		apply_landing_impact(delta)
	elif landing_offset != 0:
		smooth_reset_landing_impact(delta)
	
	camera.position.y = CAMERA_HEIGHT + current_offset + landing_offset


func _ready() -> void:
	jump.connect("jumped", Callable(self, "on_player_jumped"))
	jump.connect("landed", Callable(self, "on_player_landed"))
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
	current_amplitude = DEFAULT_AMPLITUDE * direction.velocity_vector.length() * AMPLITUDE_FACTOR
	current_frequency = DEFAULT_FREQUENCY * direction.velocity_vector.length() * FREQUENCY_FACTOR
#endregion


#region LANDING
func on_player_jumped() -> void:
	jump_start_height = player.global_position.y
	max_jump_height = jump_start_height


func track_jump_height() -> void:
	max_jump_height = max(max_jump_height, player.global_position.y)


func on_player_landed() -> void:
	is_landing = true
	landing_impact_time = 0.0
	var jump_height = max_jump_height - jump_start_height
	var height_factor = clamp(jump_height / MAX_IMPACT_HEIGHT, 0, 1)
	current_landing_impact_amplitude = lerp(BASE_LANDING_IMPACT_AMPLITUDE, MAX_LANDING_IMPACT_AMPLITUDE, height_factor)


func apply_landing_impact(delta: float) -> void:
	landing_impact_time += delta
	var impact_progress = landing_impact_time / LANDING_IMPACT_DURATION
	landing_offset = -sin(impact_progress * PI) * current_landing_impact_amplitude
	
	if landing_impact_time >= LANDING_IMPACT_DURATION:
		is_landing = false


func smooth_reset_landing_impact(delta: float) -> void:
	landing_offset = move_toward(landing_offset, 0, LANDING_RESET_SPEED * delta)
#endregion
