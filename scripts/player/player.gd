# Player.gd
# Class: Player
#
# This script manages the player's state machine, handling various aspects of
# player behavior including movement, motion, position, and actions. It provides
# a comprehensive system for tracking and updating player states, as well as
# methods for querying current and previous states.
#
# Key Components:
# - State Enums: Defines the possible states for movement, motion, position, and actions
# - State Management: Handles updating and tracking of current and previous states
# - Getter Methods: Provides methods to query current and previous states
# - Setter Methods: Allows for updating player states
# - Debug Printing: Optional state change printing for debugging purposes
#
# Usage:
# 1. Attach this script to the main player node (CharacterBody3D) in your scene.
# 2. Ensure that the Camera and Jump nodes are properly referenced.
# 3. Use the provided setter methods to update player states from other scripts.
# 4. Use the getter methods to query player states when needed.
#
# Note: This script assumes the existence of Camera and Jump nodes as children of the player.

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
@onready var jump: Jump = %Jump
#endregion


#region DEBUG
var print_state: bool = false
var print_previous_state: bool = false
#endregion


#region LIFECYCLEa
func _ready():
	#print_tree_pretty()
	pass
#endregion


#region GENERIC SETTERS
# These methods update the player's states and handle debug printing

func set_movement_state(state: int) -> void:
	if state != movement_state:
		previous_movement_state = movement_state
		movement_state = state
		if print_state: print("Movement -> ", get_movement_value())
		if print_previous_state: print("Previous Movement -> ", get_previous_movement_value())

func set_action_state(state: int) -> void:
	if state != action_state:
		previous_action_state = action_state
		action_state = state
		if print_state: print("Action -> ", get_action_value())
		if print_previous_state: print("Previous Action -> ", get_previous_action_value())

func set_motion_state(state: int) -> void:
	if state != motion_state:
		previous_motion_state = motion_state
		motion_state = state
		if print_state: print("Motion -> ", get_motion_value())
		if print_previous_state: print("Previous Motion -> ", get_previous_motion_value())

func set_position_state(state: int) -> void:
	if state != position_state:
		position_state = state
		if print_state: print("Position -> ", get_position_value())
#endregion


#region MOVEMENT SETTERS
# These methods set specific movement states
func set_still() -> void:
	set_movement_state(MovementState.STILL)

func set_forward() -> void:
	set_movement_state(MovementState.FORWARD)

func set_backward() -> void:
	set_movement_state(MovementState.BACKWARD)
#endregion


#region MOTION SETTERS
# These methods set specific motion states
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
# These methods set specific action states
func set_no_action() -> void:
	set_action_state(ActionState.NOTHING)

func set_charging_jump() -> void:
	set_action_state(ActionState.CHARGING_JUMP)

func set_jumping() -> void:
	set_action_state(ActionState.JUMPING)
#endregion


#region POSITION SETTERS
# These methods set specific position states
func set_standing() -> void:
	set_position_state(PositionState.STANDING)

func set_crouching() -> void:
	set_position_state(PositionState.CROUCHING)

func set_crouched() -> void:
	set_position_state(PositionState.CROUCHED)
#endregion


#region GENERIC GETTERS
# These methods return string representations of the current states
func get_movement_value() -> String:
	match movement_state:
		MovementState.STILL: return "STILL"
		MovementState.FORWARD: return "FORWARD"
		MovementState.BACKWARD: return "BACKWARD"
		_: return "UNKNOWN"

func get_previous_movement_value() -> String:
	match previous_movement_state:
		MovementState.STILL: return "STILL"
		MovementState.FORWARD: return "FORWARD"
		MovementState.BACKWARD: return "BACKWARD"
		_: return "UNKNOWN"

func get_motion_value() -> String:
	match motion_state:
		MotionState.IDLE: return "IDLE"
		MotionState.WALKING: return "WALKING"
		MotionState.SNEAKING: return "SNEAKING"
		MotionState.RUNNING: return "RUNNING"
		_: return "UNKNOWN"

func get_previous_motion_value() -> String:
	match previous_motion_state:
		MotionState.IDLE: return "IDLE"
		MotionState.WALKING: return "WALKING"
		MotionState.SNEAKING: return "SNEAKING"
		MotionState.RUNNING: return "RUNNING"
		_: return "UNKNOWN"

func get_action_value() -> String:
	match action_state:
		ActionState.NOTHING: return "NOTHING"
		ActionState.CHARGING_JUMP: return "CHARGING_JUMP"
		ActionState.JUMPING: return "JUMPING"
		_: return "UNKNOWN"

func get_previous_action_value() -> String:
	match previous_action_state:
		ActionState.NOTHING: return "NOTHING"
		ActionState.CHARGING_JUMP: return "CHARGING_JUMP"
		ActionState.JUMPING: return "JUMPING"
		_: return "UNKNOWN"

func get_position_value() -> String:
	match position_state:
		PositionState.STANDING: return "STANDING"
		PositionState.CROUCHING: return "CROUCHING"
		PositionState.CROUCHED: return "CROUCHED"
		_: return "UNKNOWN"
#endregion


#region MOVEMENT GETTERS
# These methods check for specific movement states
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
# These methods check for specific motion states
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
# These methods check for specific action states
func is_doing_nothing() -> bool:
	return action_state == ActionState.NOTHING

func is_charging_jump() -> bool:
	return action_state == ActionState.CHARGING_JUMP

func is_jumping() -> bool:
	return action_state == ActionState.JUMPING

func was_doing_nothing() -> bool:
	return previous_action_state == ActionState.NOTHING

func was_charging_jump() -> bool:
	return previous_action_state == ActionState.CHARGING_JUMP

func was_jumping() -> bool:
	return previous_action_state == ActionState.JUMPING
#endregion


#region POSITION GETTERS
# These methods check for specific position states
func is_standing() -> bool:
	return position_state == PositionState.STANDING

func is_crouching() -> bool:
	return position_state == PositionState.CROUCHING

func is_crouched() -> bool:
	return position_state == PositionState.CROUCHED
#endregion
