extends Node3D
class_name Player


#region STATES
enum Direction {
	STILL,
	FORWARD,
	BACKWARD,
}


enum Motion {
	IDLE,
	WALKING,
	SNEAKING,
	RUNNING,
}


enum Position {
	STANDING,
	CROUCHING_DOWN,
	CROUCHING_UP,
	CROUCHED,
}


enum Action {
	NOTHING,
	JUMPING,
	# FLYING,
	# SWIMMING...
}
#endregion


#region INITIAL STATE
@onready var direction_state: Direction = Direction.STILL
@onready var motion_state: Motion = Motion.IDLE
@onready var position_state: Position = Position.STANDING
@onready var action_state: Action = Action.NOTHING
#endregion


#region NODES
@onready var camera : PlayerCamera3D = %Camera
@onready var inputs_mouse: PlayerInputsMouse = %Inputs
@onready var jump: PlayerJump3D = %Jump
#endregion


#region LIFECYCLE
# func _ready():
	# print("Player ready. camera: ", camera, ", movement: ", movement, ", body: ", body)
	# print_tree_pretty()


func _process(_delta):
	rotation.y = camera.rotation.y
#endregion


#region GENERIC SETTERS
func set_direction_state(state: Direction) -> void:
	direction_state = state
	print("Direction -> ", get_direction_value())


func set_action_state(state: Action) -> void:
	action_state = state
	print("Action -> ", get_action_value())


func set_motion_state(state: Motion) -> void:
	motion_state = state
	print("Motion -> ", get_motion_value())


func set_position_state(state: Position) -> void:
	position_state = state
	print("Position -> ", get_position_value())
#endregion


#region DIRECTION SETTERS
func set_still() -> void:
	set_direction_state(Direction.STILL)


func set_forward() -> void:
	set_direction_state(Direction.FORWARD)


func set_backward() -> void:
	set_direction_state(Direction.BACKWARD)
#endregion


#region MOTION SETTERS
func set_idle() -> void:
	set_motion_state(Motion.IDLE)

func set_walking() -> void:
	set_motion_state(Motion.WALKING)
	
func set_sneaking() -> void:
	set_motion_state(Motion.SNEAKING)
	
func set_running() -> void:
	set_motion_state(Motion.RUNNING)
#endregion


#region ACTION SETTERS
func set_no_action() -> void:
	set_action_state(Action.NOTHING)
	

func set_jumping() -> void:
	set_action_state(Action.JUMPING)
	
# func set_action_swimming() -> void:
#	...
#endregion


#region POSITION SETTERS
func set_standing() -> void:
	set_position_state(Position.STANDING)


func set_crouching_down() -> void:
	set_position_state(Position.CROUCHING_DOWN)


func set_crouching_up() -> void:
	set_position_state(Position.CROUCHING_UP)


func set_crouched() -> void:
	set_position_state(Position.CROUCHED)
#endregion


#region GENERIC GETTERS
func get_direction_value() -> String:
	match direction_state:
		Direction.STILL:
			return "STILL"
		Direction.FORWARD:
			return "FORWARD"
		Direction.BACKWARD:
			return "BACKWARD"
		_:
			return "UNKNOWN"


func get_motion_value() -> String:
	match motion_state:
		Motion.IDLE:
			return "STILL"
		Motion.WALKING:
			return "WALKING"
		Motion.SNEAKING:
			return "SNEAKING"
		Motion.RUNNING:
			return "RUNNING"
		_:
			return "UNKNOWN"


func get_action_value() -> String:
	match action_state:
		Action.NOTHING:
			return "NOTHING"
		Action.JUMPING:
			return "JUMPING"
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
		Position.CROUCHED:
			return "CROUCHED"
		_:
			return "UNKNOWN"
#endregion


#region DIRECTION GETTERS
func is_still() -> bool:
	return direction_state == Direction.STILL


func is_moving() -> bool:
	return direction_state in [Direction.FORWARD, Direction.BACKWARD]


func is_forward() -> bool:
	return direction_state == Direction.FORWARD


func is_backward() -> bool:
	return direction_state == Direction.BACKWARD
#endregion


#region MOTION GETTERS
func is_idle() -> bool:
	return motion_state == Motion.IDLE


func is_walking() -> bool:
	return motion_state == Motion.WALKING


func is_sneaking() -> bool:
	return motion_state == Motion.SNEAKING


func is_running() -> bool:
	return motion_state == Motion.RUNNING

#endregion


#region ACTION GETTERS
func is_doing_nothing() -> bool:
	return action_state == Action.NOTHING


func is_jumping() -> bool:
	return action_state == Action.JUMPING
#endregion


#region POSITION GETTERS
func is_standing() -> bool:
	return position_state == Position.STANDING
 

func is_crouching_down() -> bool:
	return position_state == Position.CROUCHING_DOWN


func is_crouching_up() -> bool:
	return position_state == Position.CROUCHING_UP


func is_crouched() -> bool:
	return position_state == Position.CROUCHED
	

func is_crouching() -> bool:
	return position_state in [Position.CROUCHING_DOWN, Position.CROUCHING_UP, Position.CROUCHED]
#endregion
