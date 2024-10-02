# Camera.gd
# Class: Camera
#
# This script extends the Camera3D node to provide smooth camera movement,
# mouse look functionality, and dynamic field of view (FOV) adjustments based
# on player state (running, walking, crouching, jumping, slippery movement).
#
# Key Components:
# - Mouse Look: Handles mouse input for camera rotation
# - Smooth Camera Movement: Interpolates camera rotation for smooth movement
# - Dynamic FOV: Adjusts the camera's FOV based on player movement state
# - Sensitivity Settings: Allows adjustment of mouse sensitivity
# - Slippery Movement Handling: Maintains consistent FOV during slippery movement
# - Improved Jump FOV: Provides a smooth and persistent FOV change during jumps

extends Camera3D
class_name Camera


#region VARIABLES
@export var mouse_sensitivity_x: float = 0.1
@export var mouse_sensitivity_y: float = 0.002
@export var invert_y: bool = false
@export var default_fov: float = 90.0

var rotation_x: float = 0
var target_rotation: Vector3
var current_fov_change: float = 0.0
var last_movement_state: bool = false
var jump_fov_progress: float = 0.0
var is_jumping: bool = false
var fall_fov_offset: float = 0.0
var fade_rect: ColorRect
var fade_tween: Tween
#endregion


#region CONSTANTS
const CAMERA_SMOOTHNESS = 10.0
const FOV_DEFAULT: float = 70.0
const FOV_RUNNING: float = 78.0
const FOV_WALKING: float = 73.0
const FOV_CROUCHING: float = 65.0
const FOV_CROUCHED: float = 60.0
const FOV_JUMP_OFFSET: float = 5.0
const FOV_SLIPPERY: float = 75.0

const FOV_CHANGE_SPEED_RUNNING: float = 2.0
const FOV_CHANGE_SPEED_WALKING: float = 3.0
const FOV_CHANGE_SPEED_CROUCHING: float = 4.0
const FOV_CHANGE_SPEED_JUMPING: float = 1.0
const FOV_CHANGE_SPEED_SLIPPERY: float = 2.0

const FOV_JUMP_SPEED: float = 2.0
const FOV_LAND_SPEED: float = 6.0

const FOV_FALL_MAX_OFFSET: float = 15.0
const FOV_FALL_CHANGE_SPEED: float = 2.0 

const FADE_DURATION: float = 1.5
#endregion


#region NODES
@onready var movement: Movement = %Movement
@onready var jump: Jump = %Jump
@onready var player: Player = $"../../.."
@onready var gravity: Gravity = %Gravity
#endregion


#region LIFECYCLE
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	fov = default_fov
	
	rotation.x = global_rotation.x
	rotation.y = global_rotation.y
	
	jump.jumped.connect(on_player_jumped)
	jump.landed.connect(on_player_landed)
	
	setup_fade_rect()
	perform_fade_in()

	player.tree_exiting.connect(perform_fade_out)

func _process(delta: float):
	rotation.y = lerpf(rotation.y, target_rotation.y, delta * CAMERA_SMOOTHNESS)
	rotation.x = lerpf(rotation.x, target_rotation.x, delta * CAMERA_SMOOTHNESS)
	
	update_fov(delta)
#endregion


#region FADE
func setup_fade_rect():
	if not is_instance_valid(fade_rect):
		fade_rect = ColorRect.new()
		fade_rect.color = Color(0, 0, 0, 1)
		fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(fade_rect)

func perform_fade_in():
	if fade_tween:
		fade_tween.kill()
	fade_tween = create_tween()
	fade_tween.tween_property(fade_rect, "color", Color(0, 0, 0, 0), FADE_DURATION)
	fade_tween.tween_callback(func(): if is_instance_valid(fade_rect): fade_rect.queue_free())

func perform_fade_out():
	setup_fade_rect()
	fade_rect.color = Color(0, 0, 0, 0)
	if fade_tween:
		fade_tween.kill()
	fade_tween = create_tween()
	fade_tween.tween_property(fade_rect, "color", Color(0, 0, 0, 1), FADE_DURATION)
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


#region JUMP HANDLING
func on_player_jumped():
	is_jumping = true
	jump_fov_progress = 0.0

func on_player_landed():
	is_jumping = false
#endregion


#region FOV CHANGE
func update_fov(delta: float) -> void:
	var target_fov: float
	var fov_change_speed: float

	if movement.slippery:
		var is_moving = movement.velocity_vector.length() > 0.1
		target_fov = FOV_SLIPPERY if is_moving else FOV_DEFAULT
		fov_change_speed = FOV_CHANGE_SPEED_SLIPPERY
	elif player.is_on_floor():
		fall_fov_offset = 0.0
		if player.is_running():
			target_fov = FOV_RUNNING
			fov_change_speed = FOV_CHANGE_SPEED_RUNNING
		elif player.is_walking():
			target_fov = FOV_WALKING
			fov_change_speed = FOV_CHANGE_SPEED_WALKING
		elif player.is_crouching():
			target_fov = FOV_CROUCHING
			fov_change_speed = FOV_CHANGE_SPEED_CROUCHING
		elif player.is_crouched():
			target_fov = FOV_CROUCHED
			fov_change_speed = FOV_CHANGE_SPEED_CROUCHING
		else:
			target_fov = FOV_DEFAULT
			fov_change_speed = FOV_CHANGE_SPEED_WALKING
	else:
		target_fov = FOV_DEFAULT
		fov_change_speed = FOV_CHANGE_SPEED_JUMPING

		var fall_speed = abs(movement.velocity_vector.y)
		var fall_progress = clamp(fall_speed / abs(gravity.TERMINAL_VELOCITY), 0.0, 1.0)
		var target_fall_fov_offset = FOV_FALL_MAX_OFFSET * fall_progress
		fall_fov_offset = lerpf(fall_fov_offset, target_fall_fov_offset, FOV_FALL_CHANGE_SPEED * delta)

	if is_jumping:
		jump_fov_progress = min(jump_fov_progress + delta * FOV_JUMP_SPEED, 1.0)
		var jump_fov_offset = FOV_JUMP_OFFSET * sin(jump_fov_progress * PI)
		target_fov += jump_fov_offset
	elif jump_fov_progress > 0:
		jump_fov_progress = max(jump_fov_progress - delta * FOV_LAND_SPEED, 0.0)
		var jump_fov_offset = FOV_JUMP_OFFSET * sin(jump_fov_progress * PI)
		target_fov += jump_fov_offset

	target_fov += fall_fov_offset

	fov = lerpf(fov, target_fov, fov_change_speed * delta)
#endregion
