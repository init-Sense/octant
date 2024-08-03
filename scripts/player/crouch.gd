extends Node
class_name PlayerCrouch3D

#region NODES
@onready var player: CharacterBody3D = $"../.."
@onready var head: StaticBody3D = %Head
@onready var camera: Camera3D = %Camera
@onready var direction: Node = %Direction
@onready var motion: Node = %Motion
@onready var body: CollisionShape3D = $"../../Collision"
@onready var mesh: MeshInstance3D = $"../../Mesh"
#endregion


#region CONSTANTS
const CROUCH_STEPS: int = 10
const TRANSITION_TIME: float = 0.05
const STANDING_HEIGHT: float = 1.8
const CROUCHING_HEIGHT: float = 0.6
#endregion


#region VARIABLES
var current_step: float = 0
var target_step: float = 0
var current_tween: Tween
var initial_head_offset: float
#endregion


#region LIFECYCLE
func _ready() -> void:
	initial_head_offset = head.position.y - (STANDING_HEIGHT / 2)
	ensure_initial_height()


func _physics_process(delta: float) -> void:
	if current_step != target_step:
		current_step = move_toward(current_step, target_step, delta / TRANSITION_TIME)
		update_crouch()
#endregion


#region HEIGHT
func ensure_initial_height() -> void:
	body.shape.height = STANDING_HEIGHT
	mesh.mesh.height = STANDING_HEIGHT
	update_head_position(STANDING_HEIGHT)


func update_player_height(new_height: float) -> void:
	body.shape.height = new_height
	mesh.mesh.height = new_height
	update_head_position(new_height)
#endregion


func down() -> void:
	if target_step < CROUCH_STEPS:
		target_step += 1
		update_crouch_state()
		motion.on_crouch_changed()


func up() -> void:
	if target_step > 0:
		target_step -= 1
		update_crouch_state()
		motion.on_crouch_changed()


#region CROUCH LIFECYCLE
func update_crouch() -> void:
	var t: float = current_step / CROUCH_STEPS
	var new_height = lerp(STANDING_HEIGHT, CROUCHING_HEIGHT, t)
	update_player_height(new_height)


func update_crouch_state() -> void:
	if target_step == 0:
		player.set_standing()
	elif target_step == CROUCH_STEPS:
		player.set_crouched()
	else:
		player.set_crouching()


func update_head_position(body_height: float) -> void:
	head.position.y = (body_height / 2) + initial_head_offset


func get_crouch_percentage() -> float:
	return current_step / CROUCH_STEPS
#endregion
