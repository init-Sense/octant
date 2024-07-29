extends Node
class_name PlayerMovement3D


#region VARIABLES
const WALKING_SPEED: float = 3.0
const MOVEMENT_DAMPING: float = 0.01

var velocity_vector: Vector3 = Vector3.ZERO
var current_speed: float = WALKING_SPEED
#endregion


#region NODE
@onready var player: Node3D = $"../.."
@onready var camera: PlayerCamera3D = %Camera
#endregion


#region LIFECYCLE
func _ready() -> void:
	#print("PlayerMovement3D ready. player: ", player, ", camera: ", camera)
	#print_velocity_coroutine()
	pass


func _physics_process(delta) -> void:
	set_movement_velocity(delta)
	move_player()
#endregion


#region MOVEMENT
func set_movement_velocity(delta) -> void:
	var input_dir = Vector3.ZERO
	if player.is_moving_forward():
		input_dir -= camera.global_transform.basis.z
	elif player.is_moving_backward():
		input_dir += camera.global_transform.basis.z
	
	input_dir = input_dir.normalized()
	
	if player.is_on_floor():
		velocity_vector.x = input_dir.x * current_speed
		velocity_vector.z = input_dir.z * current_speed
	else:
		# Apply less control in the air
		velocity_vector.x = lerp(velocity_vector.x, input_dir.x * current_speed, delta * 2.0)
		velocity_vector.z = lerp(velocity_vector.z, input_dir.z * current_speed, delta * 2.0)
	
	if not player.is_moving():
		velocity_vector.x *= pow(MOVEMENT_DAMPING, delta)
		velocity_vector.z *= pow(MOVEMENT_DAMPING, delta)


func move_player() -> void:
	player.velocity.x = velocity_vector.x
	player.velocity.z = velocity_vector.z
	player.velocity.y = velocity_vector.y
	player.move_and_slide()


func get_movement_velocity() -> Vector3:
	return velocity_vector
#endregion


#region UTILS
func print_velocity_coroutine() -> void:
	while true:
		print("Velocity: ", Vector2(velocity_vector.x, velocity_vector.z).length())
		await get_tree().create_timer(0.2).timeout
#endregion
