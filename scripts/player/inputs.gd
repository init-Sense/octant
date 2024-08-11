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
var left_mouse_pressed: bool = false
var right_mouse_pressed: bool = false
var is_jumping: bool = false
var was_moving_forward: bool = false
#endregion


func _input(event) -> void:
	handle_jump_input(event)
	
	if is_jumping:
		handle_movement_during_jump(event)
	else:
		handle_movement_input(event)
		handle_sprint_input(event)
		handle_crouch_input(event)


#region JUMP HANDLING
func handle_jump_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			left_mouse_pressed = event.pressed
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			right_mouse_pressed = event.pressed
		
		if left_mouse_pressed and right_mouse_pressed:
			is_jumping = true
			jump.start_charge()
			was_moving_forward = Input.is_action_pressed("move_forward")
			if not was_moving_forward:
				direction.still()
				motion.stop_moving()
			motion.stop_running()
		elif not left_mouse_pressed or not right_mouse_pressed:
			is_jumping = false
			jump.release_jump()
			if not Input.is_action_pressed("move_forward"):
				direction.still()
				motion.stop_moving()


func handle_movement_during_jump(_event: InputEvent) -> void:
	if Input.is_action_pressed("move_forward") or was_moving_forward:
		direction.forward()
		motion.start_moving()
	else:
		direction.still()
		motion.stop_moving()
#endregion


#region MOVEMENT HANDLING
func handle_movement_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("move_forward"):
		direction.forward()
		motion.start_moving()
	if Input.is_action_just_pressed("move_backward"):
		direction.backward()
		motion.start_moving()
	if Input.is_action_just_released("move_forward") or Input.is_action_just_released("move_backward"):
		if not Input.is_action_pressed("move_forward") and not Input.is_action_pressed("move_backward"):
			direction.still()
			motion.stop_moving()
#endregion


#region SPRINT HANDLING
func handle_sprint_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("sprint"):
		var current_time = Time.get_ticks_msec() / 1000.0
		
		if current_time - last_sprint_tap_time <= DOUBLE_TAP_WINDOW:
			sprint_tap_count += 1
			if sprint_tap_count == 2:
				start_sprint()
				sprint_tap_count = 0
		else:
			sprint_tap_count = 1
		
		last_sprint_tap_time = current_time
	elif Input.is_action_just_released("sprint"):
		motion.stop_running() 


func start_sprint() -> void:
	if not player.is_crouching():
		motion.run()
#endregion


#region CROUCH HANDLING
func handle_crouch_input(event: InputEvent) -> void:
	if Input.is_action_pressed('debug_crouch_up'):
		crouch.up()
	elif Input.is_action_pressed('debug_crouch_down'):
		if player.is_running():
			motion.stop_running()
		crouch.down()
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			crouch.up()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			crouch.down()
#endregion
