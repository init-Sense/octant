extends Node3D


#region NODES
@onready var camera : PlayerCamera3D = $Head/PlayerCamera3D
@onready var movement : PlayerMouseMovement3D = $PlayerMouseMovement3D
@onready var body : CharacterBody3D = $PlayerBody3D
#endregion


#region LIFECYCLE
func _ready():
	print("Player ready. camera: ", camera, ", movement: ", movement, ", body: ", body)
	print_tree_pretty()


func _physics_process(_delta):
	var camera_rotation = camera.rotation
	body.rotation.y = camera_rotation.y


func _process(_delta):
	camera.global_position = body.global_position + Vector3(0, 0.5, 0)
#endregion
