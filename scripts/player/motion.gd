extends Node
class_name PlayerMotion


#region NODES
@onready var player: Player = $"../.."
@onready var direction: PlayerDirection = %Direction
@onready var crouch: PlayerCrouch = %Crouch
@onready var camera: PlayerCamera = %Camera
#endregion


#region CONSTANTS
const SPRINT_SPEED: float = 8.0
const WALKING_SPEED: float = 3.0
const SNEAKING_SPEED: float = 1.5
const DECELERATION: float = 15.0
const MAX_FOV_CHANGE: float = 12.0
const FOV_TRANSITION_SPEED: float = 50.0
const FOV_RESET_THRESHOLD: float = 0.1
#endregion


#region VARIABLES
var target_speed: float = 0.0
var current_fov_change: float = 0.0
var is_sprinting: bool = false
#endregion


#region LIFECYCLE
func _physics_process(delta: float) -> void:
	direction.current_speed = move_toward(direction.current_speed, target_speed, DECELERATION * delta)
	update_fov(delta)
#endregion


#region MOVEMENT STATES
func idle() -> void:
	player.set_idle()
	target_speed = 0.0


func walk() -> void:
	player.set_walking()
	target_speed = WALKING_SPEED


func run() -> void:
	player.set_running()
	target_speed = SPRINT_SPEED


func sneak() -> void:
	player.set_sneaking()
	update_sneaking_speed()


func update_sneaking_speed() -> void:
	var crouch_percentage = crouch.get_crouch_percentage()
	var speed_range = WALKING_SPEED - SNEAKING_SPEED
	target_speed = WALKING_SPEED - (speed_range * crouch_percentage)


func update_movement_state() -> void:
	var input_dir = direction.get_input_dir()
	
	if input_dir == Vector3.ZERO:
		idle()
	elif player.is_crouching() or player.is_crouched():
		sneak()
	elif is_sprinting and not player.is_crouched():
		run()
	else:
		walk()


func start_sprint() -> void:
	is_sprinting = true
	update_movement_state()


func stop_sprint() -> void:
	is_sprinting = false
	update_movement_state()
#endregion


#region FOV CHANGE
func update_fov(delta: float) -> void:
	var current_speed = player.velocity.length()
	var speed_ratio = current_speed / SPRINT_SPEED
	var target_fov_change = MAX_FOV_CHANGE * speed_ratio
	
	current_fov_change = move_toward(current_fov_change, target_fov_change, FOV_TRANSITION_SPEED * delta)
	
	if abs(current_fov_change) < FOV_RESET_THRESHOLD:
		current_fov_change = 0.0
	
	camera.fov = camera.default_fov + current_fov_change
#endregion
