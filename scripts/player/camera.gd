extends Camera3D
class_name Camera

#region VARIABLES
@export var mouse_sensitivity_x: float = 0.1
@export var mouse_sensitivity_y: float = 0.002
@export var invert_y: bool = false
@export var smoothness: float = 0.1
@export var default_fov: float = 90.0
var rotation_x: float = 0
var target_rotation: Vector3
var current_fov_change: float = 0.0
#endregion


#region CONSTANTS
const FOV_DEFAULT: float = 70.0

const FOV_RUNNING: float = 80.0
const FOV_WALKING: float = 75.0

const FOV_TRANSITION_RUNNING: float = 4.0
const FOV_TRANSITION_WALKING: float = 6.0

const FOV_RESET_RUNNING: float = 8.0
const FOV_RESET_WALKING: float = 3.0
#endregion


#region NODES
@onready var movement: Movement = %Movement
@onready var player = $"../../.."
#endregion


#region LIFECYCLE
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	target_rotation = rotation
	fov = default_fov
	
	
func _process(delta: float):
	rotation.y = lerp_angle(rotation.y, target_rotation.y, smoothness)
	rotation.x = lerp(rotation.x, target_rotation.x, smoothness)
	update_fov(delta)
#endregion


#region INPUT
func _input(event):
	if event is InputEventMouseMotion:
		handle_mouse_movement(event)
#endregion


#region MOVEMENT
func handle_mouse_movement(event: InputEventMouseMotion):
	var mouse_motion: Vector2 = event.relative
	
	target_rotation.y -= deg_to_rad(mouse_motion.x * mouse_sensitivity_x)
	
	var change: float = -mouse_motion.y * mouse_sensitivity_y
	
	if invert_y:
		change *= -1
	rotation_x += change
	rotation_x = clamp(rotation_x, deg_to_rad(-90), deg_to_rad(90))
	
	target_rotation.x = rotation_x
#endregion


#region ROTATION
func get_camera_rotation() -> Vector3:
	return rotation

func set_camera_rotation(new_rotation: Vector3):
	rotation = new_rotation
	target_rotation = new_rotation
	rotation_x = rotation.x
#endregion


#region SENSITIVITY
func set_sensitivity(x: float, y: float):
	mouse_sensitivity_x = x
	mouse_sensitivity_y = y
#endregion


#region FOV CHANGE
func update_fov(delta: float) -> void:
	var target_fov: float
	var fov_reset_speed: float
	var fov_transition_speed: float

	if player.is_running():
		target_fov = FOV_RUNNING
		fov_transition_speed = FOV_TRANSITION_RUNNING
		fov_reset_speed = FOV_RESET_RUNNING
	elif player.is_walking():
		target_fov = FOV_WALKING
		fov_transition_speed = FOV_TRANSITION_WALKING
		fov_reset_speed = FOV_RESET_WALKING
	else:
		fov_reset_speed = FOV_RESET_WALKING
		target_fov = FOV_DEFAULT

	if abs(fov - target_fov) < 0.1:
		fov = target_fov
	elif player.is_running() or player.is_walking():
		fov = lerp(fov, target_fov, fov_transition_speed * delta)
	else:
		fov = lerp(fov, target_fov, fov_reset_speed * delta)
#endregion
