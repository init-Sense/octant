extends Node
class_name PlayerCrouch3D


#region NODES
@onready var player: CharacterBody3D = $"../.."
@onready var head: Node3D = %Head
@onready var camera: PlayerCamera3D = %Camera
@onready var direction: PlayerMovement3D = %Direction
@onready var motion: Node = %Motion
@onready var collision: CollisionShape3D = $"../../Collision"
#endregion


#region CONSTANTS
const CROUCH_STEPS: int = 20
const TRANSITION_TIME: float = 0.1 
const STANDING_HEIGHT: float = 2.0
const CROUCHING_HEIGHT: float = 0.6
#endregion


#region VARIABLES
var current_step: int = 0
var current_tween: Tween
var initial_head_offset: float
#endregion


func _ready() -> void:
	initial_head_offset = head.position.y - collision.position.y - (collision.shape.height / 2)
	ensure_initial_height()


func ensure_initial_height() -> void:
	collision.shape.height = STANDING_HEIGHT
	update_head_position()


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
	update_collision_shape(t)
	update_head_position()


func update_crouch_state() -> void:
	if current_step == 0:
		player.set_standing()
	elif current_step == CROUCH_STEPS:
		player.set_crouched()
	else:
		player.set_crouching()


func update_collision_shape(t: float) -> void:
	var new_height = lerp(STANDING_HEIGHT, CROUCHING_HEIGHT, t)
	
	if current_tween:
		current_tween.kill()
	
	current_tween = create_tween()
	current_tween.tween_property(collision.shape, "height", new_height, TRANSITION_TIME).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	current_tween.parallel().tween_property(collision, "position:y", (STANDING_HEIGHT - new_height) / 2, TRANSITION_TIME).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	current_tween.tween_callback(update_head_position)


func update_head_position() -> void:
	var new_head_y = collision.position.y + (collision.shape.height / 2) + initial_head_offset
	head.position.y = new_head_y


func get_crouch_percentage() -> float:
	return float(current_step) / CROUCH_STEPS
