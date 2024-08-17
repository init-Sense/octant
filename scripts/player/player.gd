extends CharacterBody3D
class_name Player


#region STATES
enum MovementState {
	STILL,
	FORWARD,
	BACKWARD,
}

enum MotionState {
	IDLE,
	WALKING,
	SNEAKING,
	RUNNING,
}

enum PositionState {
	STANDING,
	CROUCHING,
	CROUCHED,
}

enum ActionState {
	NOTHING,
	CHARGING_JUMP,
	JUMPING,
	# FLYING,
	# SWIMMING...
}
#endregion


#region INITIAL STATES
@onready var movement_state: int = MovementState.STILL
@onready var motion_state: int = MotionState.IDLE
@onready var position_state: int = PositionState.STANDING
@onready var action_state: int = ActionState.NOTHING
#endregion


#region PREVIOUS STATES
@onready var previous_motion_state: int = MotionState.IDLE
@onready var previous_movement_state: int = MovementState.STILL
@onready var previous_position_state: int = PositionState.STANDING
@onready var previous_action_state: int = ActionState.NOTHING
#endregion


#region NODES
@onready var camera: Camera = %Camera
@onready var inputs_mouse: Inputs = %Inputs
@onready var jump: Jump = %Jump
#endregion


#region LIFECYCLE
func _ready():
	print_tree_pretty()


func _process(_delta):
	rotation.y = camera.rotation.y
#endregion


#region GENERIC SETTERS
func set_movement_state(state: int) -> void:
	if state != movement_state:
		previous_movement_state = movement_state
		movement_state = state
		print("Movement -> ", get_movement_value())
		print("Previous Movement -> ", get_previous_movement_value())


func set_action_state(state: int) -> void:
	if state != action_state:
		previous_action_state = action_state
		action_state = state
		print("Action -> ", get_action_value())
		print("Previous Action -> ", get_previous_action_value())


func set_motion_state(state: int) -> void:
	if state != motion_state:
		previous_motion_state = motion_state
		motion_state = state
		print("Motion -> ", get_motion_value())
		print("Previous Motion -> ", get_previous_motion_value())


func set_position_state(state: int) -> void:
	if state != position_state:
		position_state = state
		print("Position -> ", get_position_value())
#endregion


#region MOVEMENT SETTERS
func set_still() -> void:
	set_movement_state(MovementState.STILL)

func set_forward() -> void:
	set_movement_state(MovementState.FORWARD)

func set_backward() -> void:
	set_movement_state(MovementState.BACKWARD)
#endregion


#region MOTION SETTERS
func set_idle() -> void:
	set_motion_state(MotionState.IDLE)

func set_walking() -> void:
	set_motion_state(MotionState.WALKING)

func set_sneaking() -> void:
	set_motion_state(MotionState.SNEAKING)

func set_running() -> void:
	set_motion_state(MotionState.RUNNING)
#endregion


#region ACTION SETTERS
func set_no_action() -> void:
	set_action_state(ActionState.NOTHING)
	
func set_charging_jump() -> void:
	set_action_state(ActionState.CHARGING_JUMP)

func set_jumping() -> void:
	set_action_state(ActionState.JUMPING)
#endregion


#region POSITION SETTERS
func set_standing() -> void:
	set_position_state(PositionState.STANDING)

func set_crouching() -> void:
	set_position_state(PositionState.CROUCHING)

func set_crouched() -> void:
	set_position_state(PositionState.CROUCHED)
#endregion


#region GENERIC GETTERS
func get_movement_value() -> String:
	match movement_state:
		MovementState.STILL:
			return "STILL"
		MovementState.FORWARD:
			return "FORWARD"
		MovementState.BACKWARD:
			return "BACKWARD"
		_:
			return "UNKNOWN"


func get_previous_movement_value() -> String:
	match previous_movement_state:
		MovementState.STILL:
			return "STILL"
		MovementState.FORWARD:
			return "FORWARD"
		MovementState.BACKWARD:
			return "BACKWARD"
		_:
			return "UNKNOWN"


func get_motion_value() -> String:
	match motion_state:
		MotionState.IDLE:
			return "IDLE"
		MotionState.WALKING:
			return "WALKING"
		MotionState.SNEAKING:
			return "SNEAKING"
		MotionState.RUNNING:
			return "RUNNING"
		_:
			return "UNKNOWN"


func get_previous_motion_value() -> String:
	match previous_motion_state:
		MotionState.IDLE:
			return "IDLE"
		MotionState.WALKING:
			return "WALKING"
		MotionState.SNEAKING:
			return "SNEAKING"
		MotionState.RUNNING:
			return "RUNNING"
		_:
			return "UNKNOWN"


func get_action_value() -> String:
	match action_state:
		ActionState.NOTHING:
			return "NOTHING"
		ActionState.CHARGING_JUMP:
			return "CHARGING_JUMP"
		ActionState.JUMPING:
			return "JUMPING"
		_:
			return "UNKNOWN"


func get_previous_action_value() -> String:
	match previous_action_state:
		ActionState.NOTHING:
			return "NOTHING"
		ActionState.CHARGING_JUMP:
			return "CHARGING_JUMP"
		ActionState.JUMPING:
			return "JUMPING"
		_:
			return "UNKNOWN"


func get_position_value() -> String:
	match position_state:
		PositionState.STANDING:
			return "STANDING"
		PositionState.CROUCHING:
			return "CROUCHING"
		PositionState.CROUCHED:
			return "CROUCHED"
		_:
			return "UNKNOWN"
#endregion


#region MOVEMENT GETTERS
func is_still() -> bool:
	return movement_state == MovementState.STILL

func has_direction() -> bool:
	return movement_state in [MovementState.FORWARD, MovementState.BACKWARD]

func is_forward() -> bool:
	return movement_state == MovementState.FORWARD

func is_backward() -> bool:
	return movement_state == MovementState.BACKWARD

func was_still() -> bool:
	return previous_movement_state == MovementState.STILL

func had_direction() -> bool:
	return previous_movement_state in [MovementState.FORWARD, MovementState.BACKWARD]

func was_forward() -> bool:
	return previous_movement_state == MovementState.FORWARD

func was_backward() -> bool:
	return previous_movement_state == MovementState.BACKWARD
#endregion



#region MOTION GETTERS
func is_idle() -> bool:
	return motion_state == MotionState.IDLE

func is_walking() -> bool:
	return motion_state == MotionState.WALKING

func is_sneaking() -> bool:
	return motion_state == MotionState.SNEAKING

func is_running() -> bool:
	return motion_state == MotionState.RUNNING

func in_motion() -> bool:
	return motion_state in [MotionState.WALKING, MotionState.SNEAKING, MotionState.RUNNING]

func was_idle() -> bool:
	return previous_motion_state == MotionState.IDLE

func was_walking() -> bool:
	return previous_motion_state == MotionState.WALKING

func was_sneaking() -> bool:
	return previous_motion_state == MotionState.SNEAKING

func was_running() -> bool:
	return previous_motion_state == MotionState.RUNNING

func was_in_motion() -> bool:
	return previous_motion_state in [MotionState.WALKING, MotionState.SNEAKING, MotionState.RUNNING]
#endregion


#region ACTION GETTERS
func is_doing_nothing() -> bool:
	return action_state == ActionState.NOTHING

func is_charging_jump() -> bool:
	return action_state == ActionState.CHARGING_JUMP
	
func is_jumping() -> bool:
	return action_state == ActionState.JUMPING
	
func was_doing_nothing() -> bool:
	return previous_action_state == ActionState.NOTHING
	
func was_charging_jump() -> bool:
	return previous_action_state == ActionState.NOTHING
	
func was_jumping() -> bool:
	return previous_action_state == ActionState.NOTHING
#endregion


#region POSITION GETTERS
func is_standing() -> bool:
	return position_state == PositionState.STANDING

func is_crouching() -> bool:
	return position_state == PositionState.CROUCHING

func is_crouched() -> bool:
	return position_state == PositionState.CROUCHED
#endregion
