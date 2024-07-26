extends Node3D
class_name PlayerMovement3D

@export var speed : float = 5.0
@export var jump_strength : float = 4.5
@export var gravity : float = 9.8

var velocity : Vector3 = Vector3.ZERO
var is_moving : bool = false

@onready var player_body: CharacterBody3D = get_parent().get_node("PlayerBody3D")
@onready var camera: PlayerCamera3D = get_parent().get_node("PlayerCamera3D")

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
			print("Is moving: ", is_moving)

func handle_movement(delta):
	var input_dir = Vector3.ZERO
	if is_moving:
		var camera_basis = camera.global_transform.basis
		input_dir = -camera_basis.z.normalized()
		input_dir = input_dir.rotated(Vector3.UP, player_body.rotation.y)
		input_dir.y = 0
	
	velocity.x = move_toward(velocity.x, input_dir.x * speed, speed * delta)
	velocity.z = move_toward(velocity.z, input_dir.z * speed, speed * delta)

func apply_gravity(delta):
	if not player_body.is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = -0.1

func move_player():
	player_body.velocity = velocity
	player_body.move_and_slide()
	
	velocity = player_body.velocity

func get_movement_velocity() -> Vector3:
	return velocity
