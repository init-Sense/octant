# Crouch.gd
# Class: Crouch
#
# This script manages the player's crouching behavior, including smooth transitions
# between standing and crouching states, adjusting player height, and updating
# related components (like the camera and collision shape).
#
# Key Components:
# - Crouch State Management: Handles transitioning between standing, crouching, and crouched states
# - Height Adjustment: Smoothly adjusts the player's height during crouch transitions
# - Collision Shape Update: Modifies the player's collision shape to match the current crouch state
# - Camera Position Update: Adjusts the camera position based on the crouch state
# - Jump Integration: Handles uncrouch behavior during jumps
#
# Usage:
# Attach this script to a Node in your player's scene hierarchy. Ensure that
# the required child nodes (Player, Head, Camera, Movement, Collision, Mesh, Jump)
# are properly set up and accessible via the @onready variables.
#
# Note: This script assumes the existence of specific player states (is_jumping, is_on_floor)
# and methods (set_standing, set_crouched, set_crouching) in the Player script.

extends Node
class_name Crouch

#region NODES
@onready var player: Player = $"../.."
@onready var head: StaticBody3D = %Head
@onready var camera: Camera = %Camera
@onready var movement: Movement = %Movement
@onready var body: CollisionShape3D = $"../../Collision"
@onready var mesh: MeshInstance3D = $"../../Mesh"
@onready var jump: Jump = %Jump
#endregion


#region CONSTANTS
const CROUCH_STEPS: int = 2
const TRANSITION_TIME: float = 0.2
const STANDING_HEIGHT: float = 1.8
const CROUCHING_HEIGHT: float = 0.6
const JUMP_UNCROUCH_SPEED: float = 6.0
#endregion


#region VARIABLES
var current_step: float = 0
var target_step: float = 0
var current_tween: Tween
var initial_head_offset: float
var was_jumping: bool = false
#endregion


#region LIFECYCLE
func _ready() -> void:
	initial_head_offset = head.position.y - (STANDING_HEIGHT / 2)
	ensure_initial_height()


func _physics_process(delta: float) -> void:
	if player.is_jumping():
		handle_jump_crouch(delta)
	elif was_jumping and player.is_on_floor():
		handle_landing()
	elif current_step != target_step:
		handle_crouch_transition(delta)
	update_head_position()
#endregion


#region HEIGHT MANAGEMENT
func ensure_initial_height() -> void:
	body.shape.height = STANDING_HEIGHT
	mesh.mesh.height = STANDING_HEIGHT
	update_head_position()


func update_player_height(new_height: float) -> void:
	body.shape.height = new_height
	mesh.mesh.height = new_height
	update_head_position()
#endregion


#region CROUCH CONTROLS
func down() -> void:
	if not player.is_jumping() and target_step < CROUCH_STEPS:
		target_step += 1
		update_crouch_state()
		movement.update_movement_state()


func up() -> void:
	if target_step > 0:
		target_step -= 1
		update_crouch_state()
		movement.update_movement_state()


func reset_crouch() -> void:
	target_step = 0
	current_step = 0
	update_crouch_state()
	update_player_height(STANDING_HEIGHT)
	movement.update_movement_state()
#endregion


#region CROUCH LIFECYCLE
func update_crouch() -> void:
	var t: float = current_step / CROUCH_STEPS
	var new_height = lerp(STANDING_HEIGHT, CROUCHING_HEIGHT, t)
	update_player_height(new_height)
	update_crouch_state()


func update_crouch_state() -> void:
	if current_step == 0:
		player.set_standing()
	elif current_step == CROUCH_STEPS:
		player.set_crouched()
	else:
		player.set_crouching()


func update_head_position() -> void:
	var crouch_offset = (STANDING_HEIGHT - body.shape.height) / 2
	var base_position = (STANDING_HEIGHT / 2) + initial_head_offset - crouch_offset
	var jump_charge_offset: float = jump.get_charge_offset()
	head.position.y = base_position + jump_charge_offset


func get_crouch_percentage() -> float:
	return current_step / CROUCH_STEPS
#endregion


#region JUMP HANDLING
func handle_jump_crouch(delta: float) -> void:
	was_jumping = true
	current_step = move_toward(current_step, 0, delta * JUMP_UNCROUCH_SPEED)
	update_crouch()


func handle_landing() -> void:
	was_jumping = false
	reset_crouch()


func handle_crouch_transition(delta: float) -> void:
	current_step = move_toward(current_step, target_step, delta / TRANSITION_TIME)
	update_crouch()
#endregion
