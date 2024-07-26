extends Node3D
class_name PlayerCrouch3D

@onready var player_body: CharacterBody3D = $"../PlayerBody3D"
@onready var player_collision: CollisionShape3D = $"../PlayerBody3D/PlayerCollision3D"
@onready var head: Node3D = $"../Head"
@onready var player_camera: PlayerCamera3D = $"../Head/PlayerCamera3D"

const CROUCH_STEPS = 50
const CROUCH_AMOUNT = 0.8

var current_crouch_step = 0
var initial_player_height = 0
var initial_head_position = Vector3.ZERO

func _ready():
	if not player_body or not player_collision or not head or not player_camera:
		push_error("Required nodes not found in PlayerCrouch3D. Check the node structure.")
	
	initial_player_height = player_collision.shape.height
	initial_head_position = head.position

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			print('Wheel Up')
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			print('Wheel Down')
	elif event is InputEventPanGesture:
		print('Pan Gesture Detected')

func _process(delta):
	if Input.is_action_just_pressed("debug_crouch_down"):
		crouch_down()
	elif Input.is_action_just_pressed("debug_crouch_up"):
		crouch_up()

func crouch_down():
	if current_crouch_step < CROUCH_STEPS:
		current_crouch_step += 1
		update_player_height()
		print('Crouching down, step:', current_crouch_step)

func crouch_up():
	if current_crouch_step > 0:
		current_crouch_step -= 1
		update_player_height()
		print('Standing up, step:', current_crouch_step)

func update_player_height():
	var crouch_progress = float(current_crouch_step) / CROUCH_STEPS
	var height_change = initial_player_height * CROUCH_AMOUNT * crouch_progress
	var new_height = initial_player_height - height_change
	
	player_collision.shape.height = new_height
	
	head.position.y = initial_head_position.y - height_change
