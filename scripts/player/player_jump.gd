extends Node
class_name PlayerJump3D


signal action_changed(state)

@onready var player: Node3D = $".."
@onready var player_body: CharacterBody3D = %PlayerBody3D

const JUMPING_SPEED: float = 8.0

var is_jumping: bool = false
var can_jump: bool = true
var jump_velocity: Vector3


#region LIFECYCLE
func _physics_process(_delta: float) -> void:
	handle_jump()
#endregion


#region INPUT
func _input(event) -> void:
	if event is InputEventMouseButton and can_jump:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			is_jumping = true
			can_jump = false
			jump()
			emit_signal("action_changed", player.Action.JUMPING)
#endregion


#region JUMP
func handle_jump() -> void:
	if is_jumping:
		jump()
	pass


func jump() -> void:
	player_body.velocity += Vector3(0.0, JUMPING_SPEED, 0.0)
	player_body.move_and_slide()
	await get_tree().create_timer(0.1).timeout
	if player_body.is_on_floor() and is_jumping:
		is_jumping = false
		can_jump = true
		emit_signal("action_changed", player.Action.STANDING)
#endregion
