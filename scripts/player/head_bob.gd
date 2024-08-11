extends Node
class_name PlayerHeadBob

#region NODES
@onready var player: CharacterBody3D = $"../.."
@onready var camera: PlayerCamera = %Camera
@onready var direction: PlayerDirection = %Direction
@onready var jump: PlayerJump = %Jump
#endregion


#region CONSTANTS
#region HEAD BOB CONSTANTS
const DEFAULT_AMPLITUDE: float = 0.05
const DEFAULT_FREQUENCY: float = 5.0
const AMPLITUDE_FACTOR: float = 0.15
const FREQUENCY_FACTOR: float = 0.4
const RESET_SPEED: float = 1.0
const CAMERA_HEIGHT: float = 0.5
const X_FACTOR: float = 0.6
const NOISE_STRENGTH: float = 0.05
#endregion

#region LANDING CONSTANTS
const BASE_LANDING_IMPACT_AMPLITUDE: float = 0.05
const MAX_LANDING_IMPACT_AMPLITUDE: float = 0.15
const LANDING_IMPACT_DURATION: float = 0.2
const LANDING_RESET_SPEED: float = 2.0
const MAX_IMPACT_HEIGHT: float = 10.0
#endregion
#endregion


#region VARIABLES
#region HEAD BOB VARIABLES
var bob_time: float = 0.0
var current_offset: Vector3 = Vector3.ZERO
var current_amplitude: float = DEFAULT_AMPLITUDE
var current_frequency: float = DEFAULT_FREQUENCY
var is_bobbing: bool = false
var noise: FastNoiseLite = FastNoiseLite.new()
#endregion

#region LANDING VARIABLES
var landing_impact_time: float = 0.0
var is_landing: bool = false
var landing_offset: float = 0.0
var max_jump_height: float = 0.0
var jump_start_height: float = 0.0
var current_landing_impact_amplitude: float = BASE_LANDING_IMPACT_AMPLITUDE
#endregion
#endregion


#region LIFECYCLE METHODS
func _ready() -> void:
	jump.connect("jumped", Callable(self, "on_player_jumped"))
	jump.connect("landed", Callable(self, "on_player_landed"))
	noise.seed = randi()


func _physics_process(delta: float) -> void:
	handle_head_bob(delta)
	handle_landing(delta)
	update_camera_position()
#endregion


#region HEAD BOB METHODS
func handle_head_bob(delta: float) -> void:
	if player.is_moving() and not player.is_jumping():
		apply_head_bob(delta)
	elif is_bobbing:
		smooth_reset_head_bob(delta)


func apply_head_bob(delta: float) -> void:
	handle_bob_wave()
	bob_time += current_frequency * delta
	var y_offset = sin(bob_time) * current_amplitude
	var x_offset = cos(bob_time * 0.5) * current_amplitude * X_FACTOR
	
	#y_offset += noise.get_noise_1d(bob_time * 10) * NOISE_STRENGTH
	#x_offset += noise.get_noise_1d(bob_time * 10 + 100) * NOISE_STRENGTH
	
	current_offset = Vector3(x_offset, y_offset, 0)


func smooth_reset_head_bob(delta: float) -> void:
	current_offset = current_offset.move_toward(Vector3.ZERO, RESET_SPEED * delta)
	if current_offset.length() < 0.001:
		bob_time = 0
		current_offset = Vector3.ZERO
		is_bobbing = false


func handle_bob_wave() -> void:
	var speed = direction.velocity_vector.length()
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


#region CAMERA UPDATE
func update_camera_position() -> void:
	camera.position = Vector3(current_offset.x, CAMERA_HEIGHT + current_offset.y + landing_offset, current_offset.z)
#endregion
