extends Node
class_name PlayerJump3D


@onready var player: CharacterBody3D = $"../.."

const JUMPING_SPEED: float = 10.0

var has_jumped: bool = false
var jump_velocity: Vector3


#region LIFECYCLE
func _physics_process(_delta: float) -> void:
		handle_jump()
#endregion


#region JUMP
func handle_jump() -> void:
	if player.is_jumping():
		has_jumped = true
		player.velocity += Vector3(0.0, JUMPING_SPEED, 0.0)
		player.move_and_slide()
		
		await get_tree().create_timer(0.1).timeout
		
		if has_jumped and player.is_on_floor():
			has_jumped = false
			player.set_action_grounded()
#endregion
