extends Node3D
class_name PlayerMouseMovement3D


#region Variables
@export var speed : float = 3.0
@export var gravity : float = 9.8
@export var damping : float = 0.9

var velocity : Vector3 = Vector3.ZERO
var is_moving_forward : bool = false
var is_moving_backward : bool = false
var crouch_speed_factor : float = 1.0
#endregion


#region Nodes
@onready var player_body: CharacterBody3D = get_parent().get_node("PlayerBody3D")
@onready var camera: PlayerCamera3D = get_parent().get_node("Head/PlayerCamera3D")
#endregion


#region Lifecycle
func _ready() -> void:
	print("PlayerMovement3D ready. player_body: ", player_body, ", camera: ", camera)


func _process(delta) -> void:
	handle_movement(delta)
	apply_gravity(delta)
	move_player()


func _input(event) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_moving_forward = event.pressed
		if event.button_index == MOUSE_BUTTON_RIGHT:
			is_moving_backward = event.pressed
#endregion

#region Movement
func handle_movement(delta) -> void:
	var input_direction = Vector3.ZERO
	if is_moving_forward and not is_moving_backward:
		input_direction = -camera.global_transform.basis.z.normalized()
	elif is_moving_backward and not is_moving_forward:
		input_direction = camera.global_transform.basis.z.normalized()

	var target_velocity = input_direction * speed * crouch_speed_factor

	if input_direction != Vector3.ZERO:
		velocity.x = target_velocity.x
		velocity.z = target_velocity.z
	else:
		velocity.x *= damping
		velocity.z *= damping
	
	print("Velocity: ", velocity)


func move_player() -> void:
	player_body.velocity = velocity
	player_body.move_and_slide()
	velocity = player_body.velocity


func get_movement_velocity() -> Vector3:
	return velocity


func adjust_speed_for_crouch(crouch_factor: float) -> void:
	crouch_speed_factor = max(crouch_factor, 0.5)
#endregion


#region Gravity
func apply_gravity(delta) -> void:
	if not player_body.is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = -0.1
#endregion
