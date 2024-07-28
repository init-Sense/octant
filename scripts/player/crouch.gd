extends Node
class_name PlayerCrouch3D


#region NODES
@onready var player: CharacterBody3D = $"../.."
@onready var collision: CollisionShape3D = %Collision
@onready var head: Node3D = %Head
@onready var camera: PlayerCamera3D = %Camera
@onready var movement: PlayerMovement3D = %Movement
#endregion


#region CONSTANTS
const CROUCH_STEPS: float = 20
const CROUCH_AMOUNT: float = 0.95
const CROUCH_SPEED: float = 2.0
#endregion


#region VARIABLES
var current_crouch_step: float = 0
var target_crouch_step: float = 0
var initial_player_height: float = 0
var initial_head_position = Vector3.ZERO
#endregion


#region LIFECYCLE
func _ready():
	if not player or not collision or not head or not camera:
		push_error("Required nodes not found in PlayerCrouch3D. Check the node structure.")

	initial_player_height = collision.shape.height
	initial_head_position = head.position


func _input(event):
	if Input.is_action_pressed('debug_crouch_up'):
		crouch_up()
	elif Input.is_action_pressed('debug_crouch_down'):
		crouch_down()

	if event is InputEventMouseButton:
		if event.button_index ==  MOUSE_BUTTON_WHEEL_UP:
			crouch_up()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			crouch_down()
		handle_movement_speed()


func _physics_process(delta):
	if current_crouch_step != target_crouch_step:
		current_crouch_step = move_toward(current_crouch_step, target_crouch_step, CROUCH_SPEED * CROUCH_STEPS * delta )
		update_player_height()
#endregion


#region CROUCHING
func crouch_down():
	target_crouch_step = min(target_crouch_step + 1, CROUCH_STEPS)
	print('Crouching down, target step:', target_crouch_step)


func crouch_up():
	target_crouch_step = max(target_crouch_step - 1, 0)
	print('Standing up, target step:', target_crouch_step)


func handle_movement_speed() -> void:
	movement.current_speed = movement.WALKING_SPEED * (1 - current_crouch_step / CROUCH_STEPS)
	#print("Current speed: ", movement.current_speed)
#endregion


#region HEIGHT
func update_player_height():
	var crouch_progress = float(current_crouch_step) / CROUCH_STEPS
	var height_change = initial_player_height * CROUCH_AMOUNT * crouch_progress
	var new_height = initial_player_height - height_change

	collision.shape.height = new_height
	head.position.y = initial_head_position.y - height_change

	player.move_and_slide()
#endregion
