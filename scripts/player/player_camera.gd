extends Camera3D
class_name PlayerCamera3D

@export var mouse_sensitivity_x : float = 0.1
@export var mouse_sensitivity_y : float = 0.01
@export var invert_y : bool = false

var rotation_x : float = 0

func _ready():
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
    if event is InputEventMouseMotion:
        handle_mouse_movement(event)

func handle_mouse_movement(event : InputEventMouseMotion):
    var mouse_motion = event.relative
    
    rotate_y(deg_to_rad(-mouse_motion.x * mouse_sensitivity_x))
    
    var change = -mouse_motion.y * mouse_sensitivity_y
    if invert_y:
        change *= -1
    rotation_x += change
    rotation_x = clamp(rotation_x, deg_to_rad(-90), deg_to_rad(90))
    
    rotation.x = rotation_x

func get_camera_rotation() -> Vector3:
    return rotation

func set_camera_rotation(new_rotation: Vector3):
    rotation = new_rotation
    rotation_x = rotation.x

func set_sensitivity(x: float, y: float):
    mouse_sensitivity_x = x
    mouse_sensitivity_y = y