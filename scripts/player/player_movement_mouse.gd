extends Node
class_name PlayerMouseMovement3D

signal movement_changed(state)


#region VARIABLES
const WALKING_SPEED : float = 3.0
const DAMPING : float = 0.01

var velocity : Vector3 = Vector3.ZERO
var is_moving_forward : bool = false
var is_moving_backward : bool = false
var crouch_speed_factor : float = 1.0
#endregion


#region NODE
@onready var player: Node3D = $".."
@onready var player_body: CharacterBody3D = %PlayerBody3D
@onready var camera: PlayerCamera3D = %PlayerCamera3D
#endregion


#region LIFECYCLE
func _ready() -> void:
	print("PlayerMovement3D ready. player_body: ", player_body, ", camera: ", camera)
	#print_velocity_coroutine()


func _process(delta) -> void:
	handle_movement(delta)
	move_player()


func _input(event) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_moving_forward = event.pressed
			if event.pressed:
				emit_signal("movement_changed", player.Movement.FORWARD)
		if event.button_index == MOUSE_BUTTON_RIGHT:
			is_moving_backward = event.pressed
			if event.pressed:
				emit_signal("movement_changed", player.Movement.BACKWARD)
#endregion


#region MOVEMENT
func handle_movement(delta) -> void:
	var input_direction = Vector3.ZERO
	if is_moving_forward and not is_moving_backward:
		input_direction = -camera.global_transform.basis.z.normalized()
	elif is_moving_backward and not is_moving_forward:
		input_direction = camera.global_transform.basis.z.normalized()
	elif not player.is_still():
		emit_signal("movement_changed", player.Movement.STILL)

	var target_velocity = input_direction * WALKING_SPEED * crouch_speed_factor

	if input_direction != Vector3.ZERO:
		velocity.x = target_velocity.x
		velocity.z = target_velocity.z
	else:
		velocity.x *= pow(DAMPING, delta)
		velocity.z *= pow(DAMPING, delta)


func move_player() -> void:
	player_body.velocity = velocity
	player_body.move_and_slide()


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
