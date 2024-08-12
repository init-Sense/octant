extends Node
class_name PlayerDirection


#region CONSTANTS
const DEFAULT_SPEED: float = 3.0
const MOVEMENT_DAMPING: float = 0.01
const MIN_SPEED_FACTOR: float = 0.5
#endregion


#region VARIABLES
var velocity_vector: Vector3 = Vector3.ZERO
var current_speed: float = DEFAULT_SPEED
var target_velocity: Vector3 = Vector3.ZERO
#endregion


#region NODES
@onready var player: Player = $"../.."
@onready var camera: PlayerCamera = %Camera
@onready var motion: PlayerMotion = %Motion
#endregion


#region LIFECYCLE
func _physics_process(delta) -> void:
	set_movement_velocity(delta)
	move_player()
#endregion


#region MOVEMENT
func set_movement_velocity(delta) -> void:
	var input_dir = Vector3.ZERO
	if player.is_forward():
		input_dir -= camera.global_transform.basis.z
	elif player.is_backward():
		input_dir += camera.global_transform.basis.z
	
	input_dir.y = 0
	input_dir = input_dir.normalized()
	
	var speed_modifier = calculate_tilt_speed_modifier()
	
	if player.is_on_floor():
		target_velocity.x = input_dir.x * current_speed * speed_modifier
		target_velocity.z = input_dir.z * current_speed * speed_modifier
	else:
		target_velocity.x = input_dir.x * current_speed * speed_modifier
		target_velocity.z = input_dir.z * current_speed * speed_modifier
	
	var deceleration = motion.DECELERATION * delta
	velocity_vector.x = move_toward(velocity_vector.x, target_velocity.x, deceleration)
	velocity_vector.z = move_toward(velocity_vector.z, target_velocity.z, deceleration)


func move_player() -> void:
	player.velocity = velocity_vector
	player.move_and_slide()


func get_movement_velocity() -> Vector3:
	return velocity_vector


func forward() -> void:
	player.set_forward()


func backward() -> void:
	player.set_backward()


func still() -> void:
	player.set_still()
	target_velocity = Vector3.ZERO
#endregion


#region UTILS
func calculate_tilt_speed_modifier() -> float:
	var camera_forward = -camera.global_transform.basis.z
	var tilt_angle = abs(acos(camera_forward.dot(Vector3.UP)) - PI/2)
	var tilt_factor = tilt_angle / (PI/2)
	return lerp(1.0, MIN_SPEED_FACTOR, tilt_factor)


func print_velocity_coroutine() -> void:
	while true:
		print("Velocity: ", Vector2(velocity_vector.x, velocity_vector.z).length())
		await get_tree().create_timer(0.2).timeout
#endregion
