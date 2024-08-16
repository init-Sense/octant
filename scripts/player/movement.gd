extends Node
class_name Movement


#region CONSTANTS
const DEFAULT_SPEED: float = 3.0
const SPRINT_SPEED: float = 8.0
const WALKING_SPEED: float = 3.0
const SNEAKING_SPEED: float = 1.5
const WALK_DELAY: float = 0.1
const DECELERATION: float = 15.0
const MOVEMENT_DAMPING: float = 0.01
const MIN_SPEED_FACTOR: float = 0.5
#endregion


#region VARIABLES
var velocity_vector: Vector3 = Vector3.ZERO
var current_speed: float = DEFAULT_SPEED
var target_velocity: Vector3 = Vector3.ZERO
var input_dir: Vector3 = Vector3.ZERO
var target_speed: float = 0.0
var is_sprinting: bool = false
var walk_timer: float = 0.0
var is_walk_delayed: bool = false
#endregion


#region NODES
@onready var player: Player = $"../.."
@onready var camera: Camera = %Camera
@onready var climb: Climb = %Climb
@onready var crouch: Crouch = %Crouch
#endregion


#region LIFECYCLE
func _physics_process(delta) -> void:
	update_input_direction()
	current_speed = move_toward(current_speed, target_speed, DECELERATION * delta)
	update_walk_timer(delta)
	set_movement_velocity(delta)
	
	if player.is_on_floor():
		climb._last_frame_was_on_floor = Engine.get_physics_frames()
	
	player.velocity = velocity_vector
	
	if not climb._snap_up_stairs_check(delta):
		player.move_and_slide()
		climb._snap_down_the_stairs_check()


#region DIRECTION
func forward() -> void:
	input_dir = -camera.global_transform.basis.z
	input_dir.y = 0
	player.set_forward()

func backward() -> void:
	input_dir = camera.global_transform.basis.z
	input_dir.y = 0
	player.set_backward()

func still() -> void:
	input_dir = Vector3.ZERO
	target_velocity = Vector3.ZERO
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

func set_movement_velocity(delta) -> void:
	var speed_modifier: float = calculate_tilt_speed_modifier()
	
	var horizontal_velocity = input_dir * current_speed * speed_modifier
	
	velocity_vector.x = horizontal_velocity.x
	velocity_vector.z = horizontal_velocity.z
#endregion


#region DIRECTION UTILS
func update_input_direction() -> void:
	var input_vector: Vector2 = Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	
	if input_vector != Vector2.ZERO:
		var camera_basis: Basis = camera.global_transform.basis
		input_dir = (camera_basis * Vector3(input_vector.x, 0, input_vector.y)).normalized()
		input_dir.y = 0
		player.set_forward() if input_vector.y < 0 else player.set_backward()
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
	var camera_forward: Vector3 = -camera.global_transform.basis.z
	var tilt_angle              = abs(acos(camera_forward.dot(Vector3.UP)) - PI/2)
	var tilt_factor = tilt_angle / (PI/2)
	return lerp(1.0, MIN_SPEED_FACTOR, tilt_factor)
	

func update_walk_timer(delta: float) -> void:
	if is_walk_delayed:
		walk_timer += delta
		if walk_timer >= WALK_DELAY:
			update_movement_state()
#endregion
