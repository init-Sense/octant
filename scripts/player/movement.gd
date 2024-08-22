extends Node
class_name Movement


#region CONSTANTS
const SPRINT_SPEED: float = 8.0
const WALKING_SPEED: float = 4.0
const SNEAKING_SPEED: float = 1.5
const WALK_DELAY: float = 0.1
const ACCELERATION: float = 30.0
const DECELERATION: float = 15.0
const MOVEMENT_DAMPING: float = 0.01
const MIN_SPEED_FACTOR: float = 0.5
const ZERO_G_DECELERATION: float = 5.0
#endregion


#region VARIABLES
var velocity_vector: Vector3 = Vector3.ZERO
var current_speed: float = 0.0
var target_velocity: Vector3 = Vector3.ZERO
var input_dir: Vector3 = Vector3.ZERO
var target_speed: float = 0.0
var is_sprinting: bool = false
var walk_timer: float = 0.0
var is_walk_delayed: bool = false
var is_zero_g: bool = false
var zero_g_momentum: Vector3 = Vector3.ZERO
#endregion


#region NODES
@onready var player: Player = $"../.."
@onready var camera: Camera = %Camera
@onready var climb: Climb = %Climb
@onready var crouch: Crouch = %Crouch
@onready var gravity: Gravity = %Gravity
#endregion


#region LIFECYCLE
func _physics_process(delta) -> void:
	is_zero_g = gravity.GRAVITY == 0.0
	update_input_direction()
	update_velocity(delta)
	update_walk_timer(delta)
	
	if not is_zero_g and player.is_on_floor():
		climb._last_frame_was_on_floor = Engine.get_physics_frames()
	
	if is_zero_g:
		update_zero_g_momentum(delta)
		player.velocity = zero_g_momentum
	else:
		player.velocity = velocity_vector
	
	if not is_zero_g:
		if not climb._snap_up_stairs_check(delta):
			player.move_and_slide()
			climb._snap_down_the_stairs_check()
	else:
		player.move_and_slide()
#endregion


#region DIRECTION
func forward() -> void:
	input_dir = -camera.global_transform.basis.z
	if not is_zero_g:
		input_dir.y = 0
	player.set_forward()


func backward() -> void:
	input_dir = camera.global_transform.basis.z
	if not is_zero_g:
		input_dir.y = 0
	player.set_backward()


func still() -> void:
	input_dir = Vector3.ZERO
	player.set_still()
#endregion


#region MOTION
func idle() -> void:
	player.set_idle()
	target_speed = 0.0
	is_walk_delayed = false


func walk() -> void:
	if not is_walk_delayed:
		is_walk_delayed = true
		walk_timer = 0.0
	elif walk_timer >= WALK_DELAY:
		player.set_walking()
		target_speed = WALKING_SPEED
		is_walk_delayed = false


func run() -> void:
	player.set_running()
	target_speed = SPRINT_SPEED
	is_walk_delayed = false


func sneak() -> void:
	player.set_sneaking()
	update_sneaking_speed()
	is_walk_delayed = false
#endregion


#region VELOCITY UTILS
func update_sneaking_speed() -> void:
	var crouch_percentage: float = crouch.get_crouch_percentage()
	var speed_range: float = WALKING_SPEED - SNEAKING_SPEED
	target_speed = WALKING_SPEED - (speed_range * crouch_percentage)


func update_movement_state() -> void:
	if player.is_still():
		idle()
	elif player.is_crouching() or player.is_crouched():
		sneak()
	elif player.is_running() and not player.is_crouched():
		run()
	else:
		walk()


func start_sprint() -> void:
	player.set_running()
	is_walk_delayed = false
	update_movement_state()


func stop_sprint() -> void:
	update_movement_state()


func update_velocity(delta) -> void:
	var speed_modifier: float = calculate_tilt_speed_modifier()
	target_velocity = input_dir * target_speed * speed_modifier
	
	if not is_zero_g:
		var horizontal_velocity: Vector2 = Vector2(velocity_vector.x, velocity_vector.z)
		var target_horizontal_velocity: Vector2 = Vector2(target_velocity.x, target_velocity.z)
		
		if input_dir.length() > 0:
			horizontal_velocity = horizontal_velocity.move_toward(target_horizontal_velocity, ACCELERATION * delta)
		else:
			horizontal_velocity = horizontal_velocity.move_toward(Vector2.ZERO, DECELERATION * delta)
		
		velocity_vector.x = horizontal_velocity.x
		velocity_vector.z = horizontal_velocity.y
	
	current_speed = velocity_vector.length()


func update_zero_g_momentum(delta: float) -> void:
	if input_dir.length() > 0:
		zero_g_momentum += input_dir * ACCELERATION * delta
	elif zero_g_momentum.length() > 0:
		var deceleration_dir = -zero_g_momentum.normalized()
		var deceleration_amount = min(ZERO_G_DECELERATION * delta, zero_g_momentum.length())
		zero_g_momentum += deceleration_dir * deceleration_amount

	if zero_g_momentum.length() > SPRINT_SPEED:
		zero_g_momentum = zero_g_momentum.normalized() * SPRINT_SPEED
#endregion


#region DIRECTION UTILS
func update_input_direction() -> void:
	var input_vector: Vector3 = Vector3.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.z = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	
	if is_zero_g:
		input_vector.y = Input.get_action_strength("move_up") - Input.get_action_strength("move_down")
	
	if input_vector != Vector3.ZERO:
		var camera_basis: Basis = camera.global_transform.basis
		input_dir = camera_basis * input_vector
		
		if not is_zero_g:
			input_dir = input_dir.slide(Vector3.UP).normalized()
		else:
			input_dir = input_dir.normalized()
		
		player.set_forward() if input_vector.z < 0 else player.set_backward()
	else:
		input_dir = Vector3.ZERO
		player.set_still()


func get_direction() -> float:
	var forward_strength: float = Input.get_action_strength("move_forward")
	var backward_strength: float = Input.get_action_strength("move_backward")
	
	if forward_strength > backward_strength:
		return 1.0
	elif backward_strength > forward_strength:
		return -1.0
	else:
		return 0.0
#endregion


#region UTILS
func calculate_tilt_speed_modifier() -> float:
	if is_zero_g or not player.is_on_floor():
		return 1.0

	var camera_pitch: float = camera.rotation.x

	var pitch_factor = abs(camera_pitch) / (PI / 2)

	var max_slowdown: float = 0.3
	var pitch_threshold: float = 0.3

	if pitch_factor < pitch_threshold:
		return 1.0
	else:
		var slowdown_factor = (pitch_factor - pitch_threshold) / (1 - pitch_threshold)
		return 1.0 - (max_slowdown * slowdown_factor)


func update_walk_timer(delta: float) -> void:
	if is_walk_delayed:
		walk_timer += delta
		if walk_timer >= WALK_DELAY:
			update_movement_state()
#endregion
