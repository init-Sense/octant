extends Node
class_name PlayerDirection

#region CONSTANTS
const DEFAULT_SPEED: float = 3.0
const MOVEMENT_DAMPING: float = 0.01
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
func _ready() -> void:
	pass


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
	
	input_dir = input_dir.normalized()
	
	if player.is_on_floor():
		target_velocity.x = input_dir.x * current_speed
		target_velocity.z = input_dir.z * current_speed
	else:
		target_velocity.x = input_dir.x * current_speed
		target_velocity.z = input_dir.z * current_speed
	
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
func print_velocity_coroutine() -> void:
	while true:
		print("Velocity: ", Vector2(velocity_vector.x, velocity_vector.z).length())
		await get_tree().create_timer(0.2).timeout
#endregion
