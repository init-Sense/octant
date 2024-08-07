extends Node
class_name PlayerMotion


#region NODES
@onready var player: Player = $"../.."
@onready var direction: PlayerDirection = %Direction
@onready var crouch: PlayerCrouch = %Crouch
#endregion


#region CONSTANTS
const SPRINT_SPEED: float = 8.0
const WALKING_SPEED: float = 5.0
const SNEAKING_SPEED: float = 1.5
const DECELERATION: float = 15.0
#endregion


#region VARIABLES
var was_running: bool = false
var target_speed: float = 0.0
var is_moving: bool = false
#endregion


#region LIFECYCLE
func _physics_process(delta: float) -> void:
	direction.current_speed = move_toward(direction.current_speed, target_speed, DECELERATION * delta)
#endregion


#region MOVEMENT STATES
func start_moving() -> void:
	is_moving = true
	update_movement_state()


func stop_moving() -> void:
	is_moving = false
	target_speed = 0.0


func run() -> void:
	if not player.is_crouching() and not player.is_crouched() and is_moving:
		player.set_running()
		target_speed = SPRINT_SPEED
		was_running = true


func walk() -> void:
	if not player.is_crouching() and not player.is_crouched() and is_moving:
		player.set_walking()
		target_speed = WALKING_SPEED
	was_running = false


func sneak() -> void:
	player.set_sneaking()
	update_sneaking_speed()


func stop_running() -> void:
	was_running = false
	update_movement_state()


func update_sneaking_speed() -> void:
	var crouch_percentage = crouch.get_crouch_percentage()
	var speed_range = WALKING_SPEED - SNEAKING_SPEED
	target_speed = WALKING_SPEED - (speed_range * crouch_percentage)


func handle_crouch_change() -> void:
	update_movement_state()


func update_movement_state() -> void:
	if is_moving:
		if player.is_crouching() or player.is_crouched():
			sneak()
		elif was_running:
			run()
		else:
			walk()
	else:
		stop_moving()
#endregion


#region CROUCH CHECK
func on_crouch_changed() -> void:
	handle_crouch_change()

func on_stand_changed() -> void:
	handle_crouch_change()
#endregion
