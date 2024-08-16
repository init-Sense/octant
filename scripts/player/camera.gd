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
const FOV_CHANGE_WHEN_RUNNING: float = 12.0
const FOV_CHANGE_WHEN_WALKING: float = 5.0
const FOV_TRANSITION_SPEED_RUNNING: float = 50.0
const FOV_TRANSITION_SPEED_WALKING: float = 15.0
const FOV_RESET_THRESHOLD: float = 0.1
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
	var target_fov_change: float = 0.0
	var transition_speed: float = FOV_TRANSITION_SPEED_WALKING
	var direction_multiplier: float = movement.get_direction()
	
	if player.is_running():
		target_fov_change = FOV_CHANGE_WHEN_RUNNING * direction_multiplier
		transition_speed = FOV_TRANSITION_SPEED_RUNNING
	elif player.is_walking():
		target_fov_change = FOV_CHANGE_WHEN_WALKING * direction_multiplier
		transition_speed = FOV_TRANSITION_SPEED_WALKING
	else:
		target_fov_change = 0.0
		transition_speed = max(FOV_TRANSITION_SPEED_RUNNING, FOV_TRANSITION_SPEED_WALKING)
	
	current_fov_change = move_toward(current_fov_change, target_fov_change, transition_speed * delta)
	
	if abs(current_fov_change) < FOV_RESET_THRESHOLD:
		current_fov_change = 0.0
	
	fov = default_fov + current_fov_change

func reset_fov():
	fov = default_fov
#endregion
