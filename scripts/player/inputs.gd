extends Node
class_name PlayerInputsMouse


#region NODES
@onready var player: CharacterBody3D = $"../.."
@onready var movement: PlayerMovement3D = %Movement
@onready var sprint: Node = %Sprint
@onready var jump: PlayerJump3D = %Jump
@onready var crouch: PlayerCrouch3D = %Crouch
#endregion


func _input(event) -> void:
	#region MOVEMENT
	if Input.is_action_just_pressed("move_forward"):
		movement.forward()
	if Input.is_action_just_pressed("move_backward"):
		movement.backward()
	if Input.is_action_just_released("move_forward") or Input.is_action_just_released("move_backward"):
		movement.still()
	#endregion


	#region JUMP
	if Input.is_action_just_pressed("jump"):
		jump.start()
	#endregion


	#region SPRINT
	if Input.is_action_just_pressed("sprint"):
		sprint.start()
	elif Input.is_action_just_released("sprint"):
		sprint.stop()
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
