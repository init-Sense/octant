extends Node
class_name Inputs


#region NODES
@onready var movement: Movement = %Direction
@onready var motion: Motion = %Motion
@onready var jump: Jump = %Jump
@onready var crouch: Crouch = %Crouch
@onready var player: Player = $"../.."
#endregion


#region CONSTANTS
const DOUBLE_TAP_WINDOW: float = 0.3
#endregion


#region VARIABLES
var last_sprint_tap_time: float = 0.0
var sprint_tap_count: int = 0
var is_jump_charged: bool = false
#endregion


func _input(_event) -> void:
	handle_jump_input()
	
	handle_movement_input()
	handle_sprint_input()
	handle_crouch_input()


#region JUMP HANDLING
func handle_jump_input() -> void:
	if Input.is_action_pressed("jump"):
		if not is_jump_charged:
			jump.start_charge()
			is_jump_charged = true
	elif Input.is_action_just_released("jump"):
		if is_jump_charged:
			jump.release_jump()
			is_jump_charged = false
	elif not Input.is_action_pressed("jump") and is_jump_charged:
		jump.cancel_jump()
		is_jump_charged = false
#endregion


#region MOVEMENT HANDLING
func handle_movement_input() -> void:
	if Input.is_action_pressed("move_forward"):
		movement.forward()
	elif Input.is_action_pressed("move_backward"):
		movement.backward()
	else:
		movement.still()
		
	motion.update_movement_state()
#endregion


#region SPRINT HANDLING
func handle_sprint_input() -> void:
	if Input.is_action_just_pressed("run"):
		var current_time: float = Time.get_ticks_msec() / 1000.0
		
		if current_time - last_sprint_tap_time <= DOUBLE_TAP_WINDOW:
			sprint_tap_count += 1
			if sprint_tap_count == 2:
				motion.start_sprint()
				sprint_tap_count = 0
		else:
			sprint_tap_count = 1
		
		last_sprint_tap_time = current_time
	elif Input.is_action_just_released("run"):
		motion.stop_sprint()
#endregion


#region CROUCH HANDLING
func handle_crouch_input() -> void:
	if Input.is_action_pressed('crouch_up'):
		crouch.up()
	elif Input.is_action_pressed('crouch_down'):
		crouch.down()
		motion.stop_sprint()
#endregion
