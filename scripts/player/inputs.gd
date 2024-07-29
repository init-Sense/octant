extends Node
class_name PlayerInputsMouse


#region NODES
@onready var direction: PlayerMovement3D = %Direction
@onready var motion: Node = %Motion
@onready var jump: PlayerJump3D = %Jump
@onready var crouch: PlayerCrouch3D = %Crouch
#endregion


func _input(event) -> void:
	#region MOVEMENT
	if Input.is_action_just_pressed("move_forward"):
		direction.forward()
	if Input.is_action_just_pressed("move_backward"):
		direction.backward()
	if Input.is_action_just_released("move_forward") or Input.is_action_just_released("move_backward"):
		direction.still()
	#endregion


	#region JUMP
	if Input.is_action_just_pressed("jump"):
		jump.up()
	#endregion


	#region SPRINT
	if Input.is_action_just_pressed("sprint"):
		motion.run()
	elif Input.is_action_just_released("sprint"):
		motion.stop_running() 
	#endregion


	#region CROUCH
	if Input.is_action_pressed('debug_crouch_up'):
		crouch.up()
	elif Input.is_action_pressed('debug_crouch_down'):
		crouch.down()
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			crouch.up()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			crouch.down()
	#endregion
