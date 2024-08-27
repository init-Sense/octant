extends Area3D
class_name UpperElevatorArea

@export var player_path: NodePath
@export var target_position_node: NodePath
@export var transition_duration: float = 1.0
@export var recovery_time: float = 1.0

@onready var player: CharacterBody3D = get_node(player_path)
@onready var target_position: Vector3 = get_node(target_position_node).global_position

var is_transitioning: bool = false
var transition_progress: float = 0.0
var start_position: Vector3
var recovery_timer: float = 0.0

func _ready():
	area_entered.connect(_on_area_entered)

func _physics_process(delta):
	if is_transitioning:
		transition_progress += delta / transition_duration
		if transition_progress >= 1.0:
			_finish_transition()
		else:
			_update_player_position()
	elif recovery_timer > 0:
		recovery_timer -= delta

func _on_area_entered(area: Area3D):
	var player_node = find_player_node(area)
	if player_node == player and not is_transitioning and recovery_timer <= 0:
		start_transition()

func find_player_node(node: Node) -> CharacterBody3D:
	var current_node = node
	while current_node:
		if current_node is CharacterBody3D:
			return current_node
		current_node = current_node.get_parent()
	return null

func start_transition():
	is_transitioning = true
	transition_progress = 0.0
	start_position = player.global_position
	player.set_physics_process(false)

func _update_player_position():
	var new_position = start_position.lerp(target_position, ease(transition_progress, 0.5))
	player.global_position = new_position

func _finish_transition():
	is_transitioning = false
	player.global_position = target_position
	player.velocity = Vector3.ZERO
	player.set_physics_process(true)
	recovery_timer = recovery_time
	print("Transition finished. Final position: ", player.global_position)
