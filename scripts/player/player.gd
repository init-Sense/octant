extends Node3D

#region Nodes
@onready var camera : PlayerCamera3D = $Head/PlayerCamera3D
@onready var movement : PlayerMovement3D = $PlayerMovement3D
@onready var body : CharacterBody3D = $PlayerBody3D
#endregion


#region Lifecycle
func _ready():
	print("Player ready. camera: ", camera, ", movement: ", movement, ", body: ", body)

func _physics_process(delta):
	var camera_rotation = camera.rotation
	body.rotation.y = camera_rotation.y
	
func _process(delta):
	camera.global_position = body.global_position + Vector3(0, 0.5, 0)
#endregion
