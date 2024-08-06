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
const LANDING_IMPACT_AMPLITUDE: float = 0.05
const LANDING_IMPACT_DURATION: float = 0.2
const LANDING_RESET_SPEED: float = 2.0

var bob_time: float = 0.0
var current_offset: float = 0.0
var current_amplitude: float = DEFAULT_AMPLITUDE
var current_frequency: float = DEFAULT_FREQUENCY
var is_bobbing: bool = false
var landing_impact_time: float = 0.0
var is_landing: bool = false
var landing_offset: float = 0.0
#endregion

#region LIFECYCLE
func _physics_process(delta: float) -> void:
	if player.is_moving() and not player.is_jumping():
		apply_head_bob(delta)
	elif is_bobbing:
		smooth_reset_head_bob(delta)
	
	if is_landing:
		apply_landing_impact(delta)
	elif landing_offset != 0:
		smooth_reset_landing_impact(delta)
	
	camera.position.y = CAMERA_HEIGHT + current_offset + landing_offset

func _ready() -> void:
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

#region LANDING IMPACT
func on_player_landed() -> void:
	is_landing = true
	landing_impact_time = 0.0

func apply_landing_impact(delta: float) -> void:
	landing_impact_time += delta
	var impact_progress = landing_impact_time / LANDING_IMPACT_DURATION
	landing_offset = -sin(impact_progress * PI) * LANDING_IMPACT_AMPLITUDE
	
	if landing_impact_time >= LANDING_IMPACT_DURATION:
		is_landing = false

func smooth_reset_landing_impact(delta: float) -> void:
	landing_offset = move_toward(landing_offset, 0, LANDING_RESET_SPEED * delta)
#endregion
