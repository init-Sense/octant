extends Node
class_name Motion

#region NODES
@onready var player: Player = $"../.."
@onready var movement: Movement = %Movement
@onready var crouch: Crouch = %Crouch
@onready var camera: Camera = %Camera
#endregion


#region CONSTANTS
const SPRINT_SPEED: float = 8.0
const WALKING_SPEED: float = 3.0
const SNEAKING_SPEED: float = 1.5
const WALK_DELAY: float = 0.1
const DECELERATION: float = 15.0
#endregion


#region VARIABLES
var target_speed: float = 0.0
var is_sprinting: bool = false
var walk_timer: float = 0.0
var is_walk_delayed: bool = false
#endregion


#region LIFECYCLE
func _physics_process(delta: float) -> void:
	movement.current_speed = move_toward(movement.current_speed, target_speed, DECELERATION * delta)
	update_walk_timer(delta)
#endregion


#region MOTIONS
func idle() -> void:
	player.set_idle()
	target_speed = 0.0
	is_walk_delayed = false

func walk() -> void:
	if not is_walk_delayed:
		is_walk_delayed = true
		walk_timer = 0.0
	elif walk_timer >= WALK_DELAY:
		player.set_walking()
		target_speed = WALKING_SPEED
		is_walk_delayed = false

func run() -> void:
	player.set_running()
	target_speed = SPRINT_SPEED
	is_walk_delayed = false

func sneak() -> void:
	player.set_sneaking()
	update_sneaking_speed()
	is_walk_delayed = false
#endregion


#region CHANGES
func update_sneaking_speed() -> void:
	var crouch_percentage: float = crouch.get_crouch_percentage()
	var speed_range: float = WALKING_SPEED - SNEAKING_SPEED
	target_speed = WALKING_SPEED - (speed_range * crouch_percentage)

func update_movement_state() -> void:    
	if player.is_still():
		idle()
	elif player.is_crouching() or player.is_crouched():
		sneak()
	elif player.is_running() and not player.is_crouched():
		run()
	else:
		walk()

func start_sprint() -> void:
	player.set_running()
	is_walk_delayed = false
	update_movement_state()

func stop_sprint() -> void:
	update_movement_state()

func update_walk_timer(delta: float) -> void:
	if is_walk_delayed:
		walk_timer += delta
		if walk_timer >= WALK_DELAY:
			update_movement_state()
#endregion
