extends Node


#region NODES
@onready var player: Player = $"../.."
@onready var direction: PlayerMovement3D = %Direction
@onready var crouch: PlayerCrouch3D = %Crouch
#endregion


#region CONSTANTS
const SPRINT_SPEED: float = 8.0
const WALKING_SPEED: float = 5.0
const SNEAKING_SPEED: float = 1.5
#endregion


#region VARIABLES
var was_running: bool = false
#endregion


#region MOVEMENT STATES
func run() -> void:
	if not player.is_crouching() and not player.is_crouched():
		player.set_running()
		direction.current_speed = SPRINT_SPEED
		was_running = true


func walk() -> void:
	if not player.is_crouching() and not player.is_crouched():
		player.set_walking()
		direction.current_speed = WALKING_SPEED
	was_running = false


func sneak() -> void:
	player.set_sneaking()
	update_sneaking_speed()


func stop_running() -> void:
	if was_running:
		if player.is_crouching() or player.is_crouched():
			sneak()
		else:
			walk()
	was_running = false


func update_sneaking_speed() -> void:
	var crouch_percentage = crouch.get_crouch_percentage()
	var speed_range = WALKING_SPEED - SNEAKING_SPEED
	direction.current_speed = WALKING_SPEED - (speed_range * crouch_percentage)


func handle_crouch_change() -> void:
	if player.is_crouching() or player.is_crouched():
		sneak()
	elif was_running:
		run()
	else:
		walk()
#endregion


#region CROUCH CHECK
func on_crouch_changed() -> void:
	handle_crouch_change()


func on_stand_changed() -> void:
	handle_crouch_change()
#endregion
