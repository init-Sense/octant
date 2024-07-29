extends Node

@onready var player: Player = $"../.."
@onready var direction: PlayerMovement3D = %Direction
@onready var crouch: PlayerCrouch3D = %Crouch


#region CONSTANTS
const SPRINT_SPEED: float = 7.0
const WALKING_SPEED: float = 3.0
const SNEAKING_SPEED: float = 1.5
#endregion


#region VARIABLES
var current_base_speed: float = WALKING_SPEED
#endregion


#region LIFECYCLE
func _process(_delta: float) -> void:
	update_movement_speed()
#endregion


#region MOVEMENT STATES
func run() -> void:
	player.set_running()
	current_base_speed = SPRINT_SPEED
	update_movement_speed()


func walk() -> void:
	player.set_walking()
	current_base_speed = WALKING_SPEED
	update_movement_speed()


func sneak() -> void:
	player.set_sneaking()
	current_base_speed = SNEAKING_SPEED
	update_movement_speed()
#endregion


#region SPEED MANAGEMENT
func update_movement_speed() -> void:
	var speed_multiplier = 1.0
	
	if player.is_sneaking():
		speed_multiplier = 1 - (crouch.current_crouch_step / crouch.CROUCH_STEPS)
	
	direction.current_speed = current_base_speed * speed_multiplier
#endregion


#region CROUCH HANDLING
func handle_crouch_state(is_crouched: bool) -> void:
	if is_crouched:
		sneak()
	else:
		walk()
#endregion
