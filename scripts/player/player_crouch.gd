extends Node3D
class_name PlayerCrouch3D

@onready var player_body: CharacterBody3D = $"../PlayerBody3D"
@onready var player_collision: CollisionShape3D = $"../PlayerBody3D/PlayerCollision3D"
@onready var head: Node3D = $"../Head"
@onready var player_camera: PlayerCamera3D = $"../Head/PlayerCamera3D"


func _ready():
	if not player_body or not player_collision or not head or not player_camera:
		push_error("Required nodes not found in PlayerCrouch3D. Check the node structure.")

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
		print('Debug Crouch Down')
	elif Input.is_action_just_pressed("debug_crouch_up"):
		print('Debug Crouch Up')
