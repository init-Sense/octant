extends Node
class_name PlayerCrouch3D

#region NODES
@onready var player: CharacterBody3D = $"../.."
@onready var collision: CollisionShape3D = %Collision
@onready var head: Node3D = %Head
@onready var camera: PlayerCamera3D = %Camera
@onready var direction: PlayerMovement3D = %Direction
@onready var motion: Node = %Motion
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
var is_crouching_down: bool = false
#endregion


#region LIFECYCLE
func _ready():
	if not player or not collision or not head or not camera or not motion:
		push_error("Required nodes not found in PlayerCrouch3D. Check the node structure.")
	initial_player_height = collision.shape.height
	initial_head_position = head.position
#endregion


#region CROUCHING
func down():
	is_crouching_down = true
	target_crouch_step = CROUCH_STEPS
	update_crouch_state()


func up():
	is_crouching_down = false
	target_crouch_step = 0
	update_crouch_state()


func update_crouch_state():
	var delta = get_physics_process_delta_time()
	var previous_step = current_crouch_step
	
	if is_crouching_down:
		current_crouch_step = move_toward(current_crouch_step, target_crouch_step, CROUCH_SPEED * CROUCH_STEPS * delta)
	else:
		current_crouch_step = move_toward(current_crouch_step, target_crouch_step, CROUCH_SPEED * CROUCH_STEPS * delta)
	
	update_player_height()
	
	var is_crouched = current_crouch_step > 0
	motion.handle_crouch_state(is_crouched)
	
	if current_crouch_step == CROUCH_STEPS and previous_step != CROUCH_STEPS:
		player.set_crouched()
	elif current_crouch_step > previous_step:
		player.set_crouching_down()
	elif current_crouch_step == 0 and previous_step != 0:
		player.set_standing()
		motion.handle_crouch_state(false)
	elif current_crouch_step < previous_step:
		player.set_crouching_up()
#endregion


#region HEIGHT
func update_player_height():
	var crouch_progress = current_crouch_step / CROUCH_STEPS
	var height_change = initial_player_height * CROUCH_AMOUNT * crouch_progress
	var new_height = initial_player_height - height_change
	collision.shape.height = new_height
	head.position.y = initial_head_position.y - height_change
	player.move_and_slide()
#endregion
