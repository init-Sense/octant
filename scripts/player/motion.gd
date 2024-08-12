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
const FOV_CHANGE_WHEN_RUNNING: float = 12.0
const FOV_CHANGE_WHEN_WALKING: float = 3.0
const FOV_TRANSITION_SPEED_RUNNING: float = 40.0
const FOV_TRANSITION_SPEED_WALKING: float = 5.0
const FOV_RESET_THRESHOLD: float = 0.1
const WALK_DELAY: float = 0.1
#endregion


#region VARIABLES
var was_running: bool = false
var is_walking: bool = false
var target_speed: float = 0.0
var is_moving: bool = false
var current_fov_change: float = 0.0
var walk_timer: float = 0.0
var should_start_walking: bool = false
#endregion


#region LIFECYCLE
func _physics_process(delta: float) -> void:
	direction.current_speed = move_toward(direction.current_speed, target_speed, DECELERATION * delta)
	update_fov(delta)
	update_walk_timer(delta)
#endregion


#region MOVEMENT STATES
func start_moving() -> void:
	is_moving = true
	should_start_walking = true
	walk_timer = 0.0
	update_movement_state()

func stop_moving() -> void:
	is_moving = false
	is_walking = false
	should_start_walking = false
	target_speed = 0.0
	was_running = false

func run() -> void:
	if not player.is_crouching() and not player.is_crouched() and is_moving:
		player.set_running()
		target_speed = SPRINT_SPEED
		was_running = true
		is_walking = false
		should_start_walking = false

func walk() -> void:
	if not player.is_crouching() and not player.is_crouched() and is_moving:
		if should_start_walking and walk_timer >= WALK_DELAY:
			player.set_walking()
			target_speed = WALKING_SPEED
			should_start_walking = false
			is_walking = true
	was_running = false

func sneak() -> void:
	player.set_sneaking()
	update_sneaking_speed()
	was_running = false
	is_walking = false
	should_start_walking = false

func stop_running() -> void:
	was_running = false
	should_start_walking = true
	walk_timer = 0.0
	update_movement_state()

func update_sneaking_speed() -> void:
	var crouch_percentage = crouch.get_crouch_percentage()
	var speed_range = WALKING_SPEED - SNEAKING_SPEED
	target_speed = WALKING_SPEED - (speed_range * crouch_percentage)


func update_movement_state() -> void:
	if is_moving:
		if player.is_crouching() or player.is_crouched():
			sneak()
		elif was_running:
			run()
		else:
			walk()
	else:
		stop_moving()

func update_walk_timer(delta: float) -> void:
	if should_start_walking:
		walk_timer += delta
		if walk_timer >= WALK_DELAY:
			walk()
#endregion


#region FOV CHANGE
func update_fov(delta: float) -> void:
	var target_fov_change = 0.0
	var transition_speed = FOV_TRANSITION_SPEED_WALKING

	if was_running:
		target_fov_change = FOV_CHANGE_WHEN_RUNNING
		transition_speed = FOV_TRANSITION_SPEED_RUNNING
	elif is_walking:
		target_fov_change = FOV_CHANGE_WHEN_WALKING
		transition_speed = FOV_TRANSITION_SPEED_WALKING
	
	current_fov_change = move_toward(current_fov_change, target_fov_change, transition_speed * delta)
	
	if not was_running and not is_walking and abs(current_fov_change) < FOV_RESET_THRESHOLD:
		current_fov_change = 0.0
	
	camera.fov = camera.default_fov + current_fov_change
#endregion
