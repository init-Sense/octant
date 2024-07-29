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
const CROUCH_STEPS: int = 10
const TOTAL_CROUCH_DISTANCE: float = 0.9
const TRANSITION_TIME: float = 0.1 
#endregion


#region VARIABLES
var current_step: int = 0
var initial_head_position: Vector3
var current_tween: Tween
#endregion


func _ready() -> void:
	initial_head_position = head.position


func down() -> void:
	if current_step < CROUCH_STEPS:
		current_step += 1
		update_crouch()
		update_crouch_state()
		motion.on_crouch_changed()


func up() -> void:
	if current_step > 0:
		current_step -= 1
		update_crouch()
		update_crouch_state()
		motion.on_crouch_changed()

func update_crouch() -> void:
	var t: float = float(current_step) / CROUCH_STEPS
	var crouch_offset: float = TOTAL_CROUCH_DISTANCE * t
	var new_position = initial_head_position - Vector3(0, crouch_offset, 0)
	smooth_update_head_position(new_position)


func update_crouch_state() -> void:
	if current_step == 0:
		player.set_standing()
	elif current_step == CROUCH_STEPS:
		player.set_crouched()
	else:
		player.set_crouching()


func smooth_update_head_position(new_position: Vector3) -> void:
	if current_tween:
		current_tween.kill()
	
	current_tween = create_tween()
	current_tween.tween_property(head, "position", new_position, TRANSITION_TIME).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func get_crouch_percentage() -> float:
	return float(current_step) / CROUCH_STEPS
