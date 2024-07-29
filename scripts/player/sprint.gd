extends Node


@onready var player: CharacterBody3D = $"../.."
@onready var movement: PlayerMovement3D = %Movement


const SPRINT_SPEED: float = 7.0


#region LIFECYCLE
func _ready() -> void:
	player.connect("sprinting_started", Callable(self, "start_sprinting"))
	player.connect("grounded", Callable(self, "stop_sprinting"))
#endregion


#region SPRINT
func start_sprinting() -> void:
	movement.current_speed = SPRINT_SPEED


func stop_sprinting() -> void:
	movement.current_speed = movement.WALKING_SPEED
#endregion
