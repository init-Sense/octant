extends Node
class_name PlayerMovement3D


#region VARIABLES
const WALKING_SPEED: float = 5.0
const MOVEMENT_DAMPING: float = 0.01

var velocity: Vector3 = Vector3.ZERO
var current_speed: float = WALKING_SPEED
#endregion


#region NODE
@onready var player: Node3D = $"../.."
@onready var camera: PlayerCamera3D = %Camera
#endregion


#region LIFECYCLE
func _ready() -> void:
	#print("PlayerMovement3D ready. player: ", player, ", camera: ", camera)
	print_velocity_coroutine()
	pass


func _physics_process(delta) -> void:
	set_movement_velocity(delta)
	move_player()
#endregion


#region MOVEMENT
func set_movement_velocity(delta) -> void:
	if player.is_moving():
		var movement_direction = Vector3.ZERO
		if player.is_moving_forward():
			movement_direction = -camera.global_transform.basis.z.normalized()
		elif player.is_moving_backward():
			movement_direction = camera.global_transform.basis.z.normalized()

		velocity.x = movement_direction.normalized().x * current_speed
		velocity.z = movement_direction.normalized().z * current_speed

	else:
		velocity.x *= pow(MOVEMENT_DAMPING, delta)
		velocity.z *= pow(MOVEMENT_DAMPING, delta)


func move_player() -> void:
	player.velocity = velocity
	player.move_and_slide()


func get_movement_velocity() -> Vector3:
	return velocity
#endregion


#region UTILS
func print_velocity_coroutine() -> void:
	while true:
		print("Velocity: ", Vector2(velocity.x, velocity.z).length())
		await get_tree().create_timer(0.2).timeout
#endregion
