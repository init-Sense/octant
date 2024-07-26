extends Node3D
class_name PlayerMouseMovement3D

#region Variables
@export var speed : float = 3.0
@export var jump_strength : float = 4.5
@export var gravity : float = 9.8

var velocity : Vector3 = Vector3.ZERO
var is_moving : bool = false
#endregion


#region Nodes
@onready var player_body: CharacterBody3D = get_parent().get_node("PlayerBody3D")
@onready var camera: PlayerCamera3D = get_parent().get_node("Head/PlayerCamera3D")
#endregion


#region Lifecycle
func _ready():
	print("PlayerMovement3D ready. player_body: ", player_body, ", camera: ", camera)


func _process(delta):
	handle_movement(delta)
	apply_gravity(delta)
	move_player()


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_moving = event.pressed
#endregion


#region Movement
func handle_movement(delta):
	var input_dir = Vector3.ZERO
	if is_moving:
		var camera_transform = camera.global_transform

		var forward = -camera_transform.basis.z
		var right = camera_transform.basis.x

		forward = Vector3(forward.x, 0, forward.z).normalized()
		right = Vector3(right.x, 0, right.z).normalized()

		input_dir = forward

	var target_velocity = input_dir * speed
	velocity.x = move_toward(velocity.x, target_velocity.x, speed * delta)
	velocity.z = move_toward(velocity.z, target_velocity.z, speed * delta)


func move_player():
	player_body.velocity = velocity
	player_body.move_and_slide()
	
	velocity = player_body.velocity
	
	
func get_movement_velocity() -> Vector3:
	return velocity
#endregion


#region Gravity
func apply_gravity(delta):
	if not player_body.is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = -0.1
#endregion
