# Camera.gd
# Class: Camera
#
# This script extends the Camera3D node to provide smooth camera movement,
# mouse look functionality, and dynamic field of view (FOV) adjustments based
# on player state (running, walking, crouching, jumping).
#
# Key Components:
# - Mouse Look: Handles mouse input for camera rotation
# - Smooth Camera Movement: Interpolates camera rotation for smooth movement
# - Dynamic FOV: Adjusts the camera's FOV based on player movement state
# - Sensitivity Settings: Allows adjustment of mouse sensitivity
#
# Usage:
# 1. Attach this script to a Camera3D node in your scene.
# 2. Set up the necessary export variables (mouse sensitivity, smoothness, etc.)
# 3. Ensure the Movement node is properly referenced.
# 4. The script will automatically handle mouse input and FOV adjustments.
#
# Note: This script assumes the existence of specific player states (is_running,
# is_walking, etc.) in the player node.

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
const FOV_CROUCHING: float = 65.0
const FOV_CROUCHED: float = 60.0
const FOV_JUMP_OFFSET: float = 8.0

const FOV_CHANGE_SPEED_RUNNING: float = 3.0
const FOV_CHANGE_SPEED_WALKING: float = 4.0
const FOV_CHANGE_SPEED_CROUCHING: float = 6.0
const FOV_CHANGE_SPEED_JUMPING: float = 6.0

const FOV_RESET_SPEED_RUNNING: float = 8.0
const FOV_RESET_SPEED_WALKING: float = 6.0
const FOV_RESET_SPEED_CROUCHING: float = 30.0
const FOV_RESET_SPEED_JUMPING: float = 3.0
#endregion


#region NODES
@onready var movement: Movement = %Movement
@onready var player: Player = $"../../.."
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
	var fov_change_speed: float
	var fov_reset_speed: float
	var is_moving: bool = true
	
	if player.is_on_floor():
		if player.is_running():
			target_fov = FOV_RUNNING
			fov_change_speed = FOV_CHANGE_SPEED_RUNNING
			fov_reset_speed = FOV_RESET_SPEED_RUNNING
		elif player.is_walking():
			target_fov = FOV_WALKING
			fov_change_speed = FOV_CHANGE_SPEED_WALKING
			fov_reset_speed = FOV_RESET_SPEED_WALKING
		elif player.is_crouching():
			target_fov = FOV_CROUCHING
			fov_change_speed = FOV_CHANGE_SPEED_CROUCHING
			fov_reset_speed = FOV_RESET_SPEED_CROUCHING
		elif player.is_crouched():
			target_fov = FOV_CROUCHED
			fov_change_speed = FOV_CHANGE_SPEED_CROUCHING
			fov_reset_speed = FOV_RESET_SPEED_CROUCHING
		else:
			target_fov = FOV_DEFAULT
			fov_reset_speed = FOV_RESET_SPEED_WALKING
			fov_change_speed = FOV_CHANGE_SPEED_WALKING
			is_moving = false
	else:
		target_fov = FOV_DEFAULT
		fov_change_speed = FOV_CHANGE_SPEED_JUMPING
		fov_reset_speed = FOV_RESET_SPEED_JUMPING

	if player.is_jumping():
		current_fov_change = FOV_JUMP_OFFSET
	elif current_fov_change > 0:
		current_fov_change = max(0, current_fov_change - (FOV_JUMP_OFFSET * 10 * delta))

	target_fov += current_fov_change

	if abs(fov - target_fov) < 0.1:
		fov = target_fov
	else:
		var current_fov_change_speed = fov_change_speed if is_moving else fov_reset_speed
		fov = lerpf(fov, target_fov, current_fov_change_speed * delta)
#endregion
