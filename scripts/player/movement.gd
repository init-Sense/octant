extends Node
class_name PlayerMovement3D


#region VARIABLES
const WALKING_SPEED : float = 3.0
const MOVEMENT_DAMPING : float = 0.01

var velocity : Vector3 = Vector3.ZERO
var crouch_speed_factor : float = 1.0
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


func _process(delta) -> void:
	handle_movement(delta)
	move_player()
#endregion


#region MOVEMENT
func handle_movement(delta) -> void:
	var input_direction = Vector3.ZERO
	if player.is_moving_forward():
		input_direction = -camera.global_transform.basis.z.normalized()
	elif player.is_moving_backward():
		input_direction = camera.global_transform.basis.z.normalized()

	var target_velocity = input_direction * WALKING_SPEED * crouch_speed_factor

	if input_direction != Vector3.ZERO:
		velocity.x = target_velocity.x
		velocity.z = target_velocity.z
	else:
		velocity.x *= pow(MOVEMENT_DAMPING, delta)
		velocity.z *= pow(MOVEMENT_DAMPING, delta)


func move_player() -> void:
	player.velocity = velocity
	player.move_and_slide()


func get_movement_velocity() -> Vector3:
	return velocity


func adjust_speed_for_crouch(crouch_factor: float) -> void:
	crouch_speed_factor = max(crouch_factor, 0.5)
#endregion


#region UTILS
func print_velocity_coroutine() -> void:
	while true:
		print("Velocity: ", velocity)
		await get_tree().create_timer(1).timeout
#endregion
