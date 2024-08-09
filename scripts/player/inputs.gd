extends Node
class_name PlayerInputs

#region NODES
@onready var direction: PlayerDirection = %Direction
@onready var motion: PlayerMotion = %Motion
@onready var jump: PlayerJump = %Jump
@onready var crouch: PlayerCrouch = %Crouch
@onready var player: CharacterBody3D = $"../.."
#endregion

func _input(event) -> void:
	#region MOVEMENT
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

	#region JUMP
	if Input.is_action_just_pressed("jump"):
		jump.start_charge()
	elif Input.is_action_just_released("jump"):
		jump.release_jump()
	#endregion

	#region SPRINT
	if Input.is_action_just_pressed("sprint") and not player.is_crouching():
		motion.run()
	elif Input.is_action_just_released("sprint"):
		motion.stop_running() 
	#endregion

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
