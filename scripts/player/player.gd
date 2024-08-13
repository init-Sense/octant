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
	CROUCHING,
	CROUCHED,
}


enum Action {
	NOTHING,
	JUMPING,
	# FLYING,
	# SWIMMING...
}
#endregion


#region INITIAL STATES
@onready var direction_state: Direction = Direction.STILL
@onready var motion_state: Motion = Motion.IDLE
@onready var position_state: Position = Position.STANDING
@onready var action_state: Action = Action.NOTHING
#endregion


#region PREVIOUS STATES
@onready var previous_motion_state: Motion = Motion.IDLE
#endregion


#region NODES
@onready var camera: PlayerCamera = %Camera
@onready var inputs_mouse: PlayerInputs = %Inputs
@onready var jump: PlayerJump = %Jump
#endregion


#region LIFECYCLE
func _ready():
	print_tree_pretty()


func _process(_delta):
	rotation.y = camera.rotation.y
#endregion


#region GENERIC SETTERS
func set_direction_state(state: Direction) -> void:
	if state != direction_state:
		direction_state = state
		print("Direction -> ", get_direction_value())

func set_action_state(state: Action) -> void:
	if state != action_state:
		action_state = state
		print("Action -> ", get_action_value())

func set_motion_state(state: Motion) -> void:
	if state != motion_state:
		previous_motion_state = motion_state
		motion_state = state
		print("Motion -> ", get_motion_value())
		print("Previous Motion -> ", get_previous_motion_value())

func set_position_state(state: Position) -> void:
	if state != position_state:
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
#endregion


#region POSITION SETTERS
func set_standing() -> void:
	set_position_state(Position.STANDING)


func set_crouching() -> void:
	set_position_state(Position.CROUCHING)


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
			return "IDLE"
		Motion.WALKING:
			return "WALKING"
		Motion.SNEAKING:
			return "SNEAKING"
		Motion.RUNNING:
			return "RUNNING"
		_:
			return "UNKNOWN"


func get_previous_motion_value() -> String:
	match previous_motion_state:
		Motion.IDLE:
			return "IDLE"
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
		Position.CROUCHING:
			return "CROUCHING"
		Position.CROUCHED:
			return "CROUCHED"
		_:
			return "UNKNOWN"
#endregion


#region DIRECTION GETTERS
func is_still() -> bool:
	return direction_state == Direction.STILL


func has_direction() -> bool:
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

func in_motion() -> bool:
	return motion_state in [Motion.WALKING, Motion.SNEAKING, Motion.RUNNING]

func was_idle() -> bool:
	return previous_motion_state == Motion.IDLE

func was_walking() -> bool:
	return previous_motion_state == Motion.WALKING

func was_sneaking() -> bool:
	return previous_motion_state == Motion.SNEAKING

func was_running() -> bool:
	return previous_motion_state == Motion.RUNNING

func was_in_motion() -> bool:
	return previous_motion_state in [Motion.WALKING, Motion.SNEAKING, Motion.RUNNING]
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


func is_crouching() -> bool:
	return position_state == Position.CROUCHING


func is_crouched() -> bool:
	return position_state == Position.CROUCHED
#endregion
