extends Node3D
class_name PlayerCrouch3D

@export var crouch_step : float = 0.05
@export var min_crouch : float = 0.5
@export var max_height : float = 2.0
@export var pan_sensitivity : float = 0.01

var current_height : float = max_height

@onready var player_body : CharacterBody3D = get_parent().get_node("PlayerBody3D")
@onready var player_collision : CollisionShape3D = player_body.get_node("PlayerCollision3D")
@onready var head : Node3D = get_parent().get_node("Head")

func _ready():
	if not player_body or not player_collision or not head:
		push_error("Required nodes not found in PlayerCrouch3D. Check the node structure.")

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			print('Wheel Up')
			adjust_crouch(-crouch_step)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			print('Wheel Down')
			adjust_crouch(crouch_step)
	elif event is InputEventPanGesture:
		print('Pan Gesture Detected')
		var pan_amount = -event.delta.y * pan_sensitivity
		adjust_crouch(pan_amount)
		print("Current height: ", current_height)

func adjust_crouch(amount: float):
	var new_height = clamp(current_height + amount, min_crouch, max_height)
	if new_height != current_height:
		current_height = new_height
		update_player_height()

func update_player_height():
	if player_collision.shape is CapsuleShape3D:
		player_collision.shape.height = current_height
		player_collision.position.y = current_height / 2

	head.position.y = current_height - 0.2

	var movement_script = get_parent().get_node("PlayerMouseMovement3D")
	if movement_script:
		var crouch_factor = current_height / max_height
		movement_script.adjust_speed_for_crouch(crouch_factor)

func get_crouch_factor() -> float:
	return current_height / max_height
