extends Node3D


#region PLAYER STATES
enum Movement {
	STILL,
	FORWARD,
	BACKWARD,
}

enum Action {
	STANDING,
	CROUCHING,
	JUMPING,
	FLYING,
	SWIMMING
}

var movement_state: Movement
var action_state: Action
#endregion


#region NODES
@onready var camera : PlayerCamera3D = $Head/PlayerCamera3D
@onready var movement : PlayerMovementMouse3D = $PlayerMovementMouse3D
@onready var body : CharacterBody3D = $PlayerBody3D
@onready var jump: PlayerJump3D = $PlayerJump3D
#endregion


#region LIFECYCLE
func _ready():
	print("Player ready. camera: ", camera, ", movement: ", movement, ", body: ", body)
	print_tree_pretty()
	movement.connect("movement_changed", Callable(self, "set_movement_state"))
	jump.connect("action_changed", Callable(self, "set_action_state"))
	set_movement_still()


func _process(_delta):
	var camera_rotation = camera.rotation
	body.rotation.y = camera_rotation.y
	camera.global_position = body.global_position + Vector3(0, 0.5, 0)
#endregion


#region SETTERS
func set_movement_state(state) -> void:
	movement_state = state
	print("Movement: ", get_movement_value())


func set_action_state(state) -> void:
	action_state = state
	print("Action: ", get_action_value())


func set_movement_still() -> void:
	set_movement_state(Movement.STILL)


func set_movement_forward() -> void:
	set_movement_state(Movement.FORWARD)


func set_movement_backward() -> void:
	set_movement_state(Movement.BACKWARD)


func set_action_standing() -> void:
	set_action_state(Action.STANDING)


func set_action_crouching() -> void:
	set_action_state(Action.CROUCHING)


func set_action_jumping() -> void:
	set_action_state(Action.JUMPING)
#endregion


#region GETTERS
func get_movement_value() -> String:
	match movement_state:
		Movement.STILL:
			return "STILL"
		Movement.FORWARD:
			return "FORWARD"
		Movement.BACKWARD:
			return "BACKWARD"
		_:
			return "UNKNOWN"


func get_action_value() -> String:
	match action_state:
		Action.STANDING:
			return "STANDING"
		Action.CROUCHING:
			return "CROUCHING"
		Action.JUMPING:
			return "JUMPING"
		Action.FLYING:
			return "FLYING"
		Action.SWIMMING:
			return "SWIMMING"
		_:
			return "UNKNOWN"


func is_still() -> bool:
	return movement_state == Movement.STILL


func is_moving_forward() -> bool:
	return movement_state == Movement.FORWARD


func is_moving_backward() -> bool:
	return movement_state == Movement.BACKWARD


func is_standing() -> bool:
	return action_state == Action.STANDING


func is_crouching() -> bool:
	return action_state == Action.CROUCHING


func is_jumping() -> bool:
	return action_state == Action.JUMPING
#endregion
