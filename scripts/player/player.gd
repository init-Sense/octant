extends Node3D


#region PLAYER STATES
enum Movement {
	STILL,
	FORWARD,
	BACKWARD,
}

enum Action {
	GROUNDED,
	JUMPING,
	FLYING,
	SWIMMING,
}

enum Position {
	STANDING,
	CROUCHING_DOWN,
	CROUCHING_UP,
	CROUCHED,
}

var movement_state: Movement
var action_state: Action
var position_state: Position
#endregion


#region NODES
@onready var camera : PlayerCamera3D = $PlayerBody/Head/PlayerCamera
@onready var body : CharacterBody3D = $PlayerBody
@onready var inputs_mouse: PlayerInputsMouse = $PlayerInputsMouse
@onready var jump: PlayerJump3D = $PlayerJump
#endregion


#region LIFECYCLE
func _ready():
	#print("Player ready. camera: ", camera, ", movement: ", movement, ", body: ", body)
	#print_tree_pretty()
	jump.connect("action_changed", Callable(self, "set_action_state"))
	set_movement_still()
	set_action_grounded()
	set_position_standing()


func _process(_delta):
	body.rotation.y = camera.rotation.y
#endregion


#region SETTERS
func set_movement_state(state) -> void:
	movement_state = state
	print("Movement: ", get_movement_value())


func set_action_state(state) -> void:
	action_state = state
	print("Action: ", get_action_value())


func set_position_state(state) -> void:
	position_state = state
	print("Position: ", get_position_value())


func set_movement_still() -> void:
	set_movement_state(Movement.STILL)


func set_movement_forward() -> void:
	set_movement_state(Movement.FORWARD)


func set_movement_backward() -> void:
	set_movement_state(Movement.BACKWARD)


func set_action_grounded() -> void:
	set_action_state(Action.GROUNDED)


func set_action_jumping() -> void:
	set_action_state(Action.JUMPING)


func set_position_standing() -> void:
	set_action_state(Position.STANDING)


func set_position_crouching_down() -> void:
	set_action_state(Position.CROUCHING_DOWN)


func set_position_crouching_up() -> void:
	set_action_state(Position.CROUCHING_UP)


func set_position_crouched() -> void:
	set_action_state(Position.CROUCHED)
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
		Action.GROUNDED:
			return "GROUNDED"
		Action.JUMPING:
			return "JUMPING"
		Action.FLYING:
			return "FLYING"
		Action.SWIMMING:
			return "SWIMMING"
		_:
			return "UNKNOWN"


func get_position_value() -> String:
	match position_state:
		Position.STANDING:
			return "STANDING"
		Position.CROUCHING_DOWN:
			return "CROUCHING_DOWN"
		Position.CROUCHING_UP:
			return "CROUCHING_UP"
		_:
			return "UNKNOWN"

func is_still() -> bool:
	return movement_state == Movement.STILL


func is_moving() -> bool:
	return movement_state in [Movement.FORWARD, Movement.BACKWARD]


func is_moving_forward() -> bool:
	return movement_state == Movement.FORWARD


func is_moving_backward() -> bool:
	return movement_state == Movement.BACKWARD


func is_jumping() -> bool:
	return action_state == Action.JUMPING


func is_standing() -> bool:
	return position_state == Position.STANDING


func is_crouching_down() -> bool:
	return position_state == Position.CROUCHING_DOWN


func is_crouching_up() -> bool:
	return position_state == Position.CROUCHING_UP


func is_crouched() -> bool:
	return position_state == Position.CROUCHED
#endregion


#region SIGNALS
func _on_player_inputs_mouse_action_changed(state: Variant) -> void:
	set_action_state(state)


func _on_player_inputs_mouse_movement_changed(state: Variant) -> void:
	set_movement_state(state)


func _on_player_crouch_position_changed(state: Variant) -> void:
	set_position_state(state)
#endregion
