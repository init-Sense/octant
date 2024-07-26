extends Node3D

@onready var camera : PlayerCamera3D = $PlayerCamera3D
@onready var movement : PlayerMovement3D = $PlayerMovement3D
@onready var body : CharacterBody3D = $PlayerBody3D

func _ready():
	print("Player ready. camera: ", camera, ", movement: ", movement, ", body: ", body)

func _physics_process(delta):
	# print("Player _physics_process called")
	var camera_rotation = camera.rotation
	body.rotation.y = camera_rotation.y
	
	movement.physics_process(delta)

func _process(delta):
	camera.global_position = body.global_position + Vector3(0, 0.5, 0)
