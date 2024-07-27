extends Node
class_name PlayerCrouch3D


#region NODES
@onready var player_body: CharacterBody3D = %PlayerBody3D
@onready var player_collision: CollisionShape3D = $"../PlayerBody3D/PlayerCollision3D"
@onready var head: Node3D = $"../Head"
@onready var player_camera: PlayerCamera3D = %PlayerCamera3D
#endregion


#region CONSTANTS
const CROUCH_STEPS = 10
const CROUCH_AMOUNT = 0.9
const CROUCH_SPEED = 6
#endregion


#region VARIABLES
var current_crouch_step = 0
var target_crouch_step = 0
var initial_player_height = 0
var initial_head_position = Vector3.ZERO
#endregion


#region LIFECYCLE
func _ready():
	if not player_body or not player_collision or not head or not player_camera:
		push_error("Required nodes not found in PlayerCrouch3D. Check the node structure.")
	
	initial_player_height = player_collision.shape.height
	initial_head_position = head.position


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			print('Wheel Up')
			crouch_up()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			print('Wheel Down')
			crouch_down()
	elif event is InputEventPanGesture:
		print('Pan Gesture Detected')


func _process(delta):
	if Input.is_action_just_pressed("debug_crouch_down"):
		crouch_down()
	elif Input.is_action_just_pressed("debug_crouch_up"):
		crouch_up()
	
	if current_crouch_step != target_crouch_step:
		current_crouch_step = move_toward(current_crouch_step, target_crouch_step, CROUCH_SPEED * delta * CROUCH_STEPS)
		update_player_height()
#endregion


#region CROUCHING
func crouch_down():
	target_crouch_step = min(target_crouch_step + 1, CROUCH_STEPS)
	print('Crouching down, target step:', target_crouch_step)

func crouch_up():
	target_crouch_step = max(target_crouch_step - 1, 0)
	print('Standing up, target step:', target_crouch_step)
#endregion


#region HEIGHT
func update_player_height():
	var crouch_progress = float(current_crouch_step) / CROUCH_STEPS
	var height_change = initial_player_height * CROUCH_AMOUNT * crouch_progress
	var new_height = initial_player_height - height_change
	
	player_collision.shape.height = new_height
	head.position.y = initial_head_position.y - height_change
	
	player_body.move_and_slide()
#endregion
