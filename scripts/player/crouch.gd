extends Node
class_name PlayerCrouch3D


#region NODES
@onready var player: CharacterBody3D = $"../.."
@onready var head: Node3D = %Head
@onready var camera: PlayerCamera3D = %Camera
@onready var direction: PlayerMovement3D = %Direction
@onready var motion: Node = %Motion
#endregion


#region CONSTANTS
const CROUCH_STEPS: int = 20
const TOTAL_CROUCH_DISTANCE: float = 0.9
#endregion


#region VARIABLES
var current_step: int = 0
var initial_head_position: Vector3
#endregion


func _ready() -> void:
	initial_head_position = head.position


func down() -> void:
	if current_step < CROUCH_STEPS:
		current_step += 1
		update_crouch()
		update_crouch_state()


func up() -> void:
	if current_step > 0:
		current_step -= 1
		update_crouch()
		update_crouch_state()


func update_crouch() -> void:
	var t: float = float(current_step) / CROUCH_STEPS
	var crouch_offset: float = TOTAL_CROUCH_DISTANCE * t
	var new_position = initial_head_position - Vector3(0, crouch_offset, 0)
	update_head_position(new_position)


func update_crouch_state() -> void:
	if current_step == 0:
		player.set_standing()
	elif current_step == CROUCH_STEPS:
		player.set_crouched()
	else:
		player.set_crouching()


func update_head_position(new_position: Vector3) -> void:
	head.position = new_position


func get_crouch_percentage() -> float:
	return float(current_step) / CROUCH_STEPS
