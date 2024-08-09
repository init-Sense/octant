extends Camera3D
class_name PlayerCamera


#region VARIABLES
@export var mouse_sensitivity_x: float = 0.1
@export var mouse_sensitivity_y: float = 0.002
@export var invert_y: bool = false
@export var smoothness: float = 0.1

var rotation_x: float = 0
var target_rotation: Vector3
#endregion


#region LIFECYCLE
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	target_rotation = rotation
#endregion


#region INPUT
func _input(event):
	if event is InputEventMouseMotion:
		handle_mouse_movement(event)
#endregion


#region MOVEMENT
func handle_mouse_movement(event: InputEventMouseMotion):
	var mouse_motion = event.relative
	
	target_rotation.y -= deg_to_rad(mouse_motion.x * mouse_sensitivity_x)
	
	var change = -mouse_motion.y * mouse_sensitivity_y
	
	if invert_y:
		change *= -1
	rotation_x += change
	rotation_x = clamp(rotation_x, deg_to_rad(-90), deg_to_rad(90))
	
	target_rotation.x = rotation_x
#endregion


#region PROCESS
func _process(_delta):
	rotation.y = lerp_angle(rotation.y, target_rotation.y, smoothness)
	rotation.x = lerp(rotation.x, target_rotation.x, smoothness)
#endregion


#region ROTATION
func get_camera_rotation() -> Vector3:
	return rotation

func set_camera_rotation(new_rotation: Vector3):
	rotation = new_rotation
	target_rotation = new_rotation
	rotation_x = rotation.x
#endregion


#region SENSITIVITY
func set_sensitivity(x: float, y: float):
	mouse_sensitivity_x = x
	mouse_sensitivity_y = y
#endregion
