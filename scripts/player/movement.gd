extends Node
class_name PlayerMovement3D

#region VARIABLES
const WALKING_SPEED: float = 3.0
const MOVEMENT_DAMPING: float = 0.01
var velocity_vector: Vector3 = Vector3.ZERO
var current_speed: float = WALKING_SPEED
var movement_state: int = 0  # 0: still, 1: forward, -1: backward
#endregion

#region NODE
@onready var player: CharacterBody3D = $"../.."
@onready var camera: PlayerCamera3D = %Camera
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
	if movement_state == 1:  # forward
		input_dir -= camera.global_transform.basis.z
	elif movement_state == -1:  # backward
		input_dir += camera.global_transform.basis.z
	
	input_dir = input_dir.normalized()
	
	if player.is_on_floor():
		velocity_vector.x = input_dir.x * current_speed
		velocity_vector.z = input_dir.z * current_speed
	else:
		velocity_vector.x = lerp(velocity_vector.x, input_dir.x * current_speed, delta * 2.0)
		velocity_vector.z = lerp(velocity_vector.z, input_dir.z * current_speed, delta * 2.0)
	
	if movement_state == 0:
		velocity_vector.x *= pow(MOVEMENT_DAMPING, delta)
		velocity_vector.z *= pow(MOVEMENT_DAMPING, delta)

func move_player() -> void:
	player.velocity = velocity_vector
	player.move_and_slide()

func get_movement_velocity() -> Vector3:
	return velocity_vector

func forward() -> void:
	movement_state = 1
	player.set_forward()

func backward() -> void:
	movement_state = -1
	player.set_backward()

func still() -> void:
	movement_state = 0
	player.set_still()
#endregion

#region UTILS
func print_velocity_coroutine() -> void:
	while true:
		print("Velocity: ", Vector2(velocity_vector.x, velocity_vector.z).length())
		await get_tree().create_timer(0.2).timeout
#endregion
