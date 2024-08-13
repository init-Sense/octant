extends Node
class_name PlayerInputs


#region NODES
@onready var direction: PlayerDirection = %Direction
@onready var motion: PlayerMotion = %Motion
@onready var jump: PlayerJump = %Jump
@onready var crouch: PlayerCrouch = %Crouch
@onready var player: CharacterBody3D = $"../.."
#endregion


#region CONSTANTS
const DOUBLE_TAP_WINDOW: float = 0.3
#endregion


#region VARIABLES
var last_sprint_tap_time: float = 0.0
var sprint_tap_count: int = 0
var is_jumping: bool = false
#endregion


func _input(_event) -> void:
	handle_jump_input()
	
	if is_jumping:
		handle_movement_during_jump()
	else:
		handle_movement_input()
		handle_sprint_input()
		handle_crouch_input()


#region JUMP HANDLING
func handle_jump_input() -> void:    
	if Input.is_action_pressed("move_forward") and Input.is_action_pressed("move_backward"):
		if not is_jumping:
			is_jumping = true
			jump.start_charge()
			if Input.is_action_pressed("move_forward") and player.is_forward():
				direction.forward()
			elif Input.is_action_pressed("move_backward") and player.is_backward():
				direction.backward()
			else:
				direction.still()
	elif not Input.is_action_pressed("move_forward") or not Input.is_action_pressed("move_backward"):
		is_jumping = false
		jump.release_jump()
		
		if not Input.is_action_pressed("move_forward") and not Input.is_action_pressed("move_backward"):
			direction.still()


func handle_movement_during_jump() -> void:
	if Input.is_action_pressed("move_forward") and player.is_forward():
		direction.forward()
	elif Input.is_action_pressed("move_backward") and player.is_backward():
		direction.backward()
	else:
		direction.still()
#endregion


#region MOVEMENT HANDLING
func handle_movement_input() -> void:
	if Input.is_action_pressed("move_forward"):
		direction.forward()
	elif Input.is_action_pressed("move_backward"):
		direction.backward()
	else:
		direction.still()
	
	motion.update_movement_state()
#endregion


#region SPRINT HANDLING
func handle_sprint_input() -> void:
	if Input.is_action_just_pressed("run"):
		var current_time = Time.get_ticks_msec() / 1000.0
		
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
