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
#endregion


func _input(_event) -> void:
	handle_jump_input()
	
	if player.is_charging_jump():
		handle_movement_during_jump()
	else:
		handle_movement_input()
		handle_sprint_input()
		handle_crouch_input()


#region JUMP HANDLING
func handle_jump_input() -> void:
	if Input.is_action_pressed("move_forward") and Input.is_action_pressed("move_backward"):
		if not player.is_charging_jump():
			jump.start_charge()
	else:
		if player.is_charging_jump():
			jump.release_jump()
			reset_movement()


func handle_movement_during_jump() -> void:
	if not player.is_charging_jump():
		return
	
	if player.is_forward():
		if Input.is_action_pressed("move_forward"):
			movement.forward()
		else:
			movement.still()
	elif player.is_backward():
		if Input.is_action_pressed("move_backward"):
			movement.backward()
		else:
			movement.still()
	elif player.is_still():
		movement.still()


func reset_movement() -> void:
	if player.is_forward():
		movement.forward()
	elif player.is_backward():
		movement.backward()
	else:
		movement.still()
#endregion


#region MOVEMENT HANDLING
func handle_movement_input() -> void:
	if not player.is_charging_jump():
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
