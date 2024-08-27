extends Area3D
class_name Transport

@export var player_path: NodePath
@export var target_position_node: NodePath
@export var transition_duration: float = 1.0
@export var post_transport_ignore_time: float = 5.0
@export_flags_3d_physics var floor_collision_layer: int = 1

@onready var player: Player = get_node(player_path)
@onready var player_movement: Jump = player.get_node("Modules/Jump") if player else null
@onready var target_y_position: float = get_node(target_position_node).global_position.y

var is_transitioning: bool = false
var transition_progress: float = 0.0
var start_y_position: float
var original_collision_mask: int
var last_y_velocity: float = 0.0
var is_upward_transport: bool = false

static var is_any_elevator_active: bool = false
static var cooldown_timer: float = 0.0

func _ready():
	area_entered.connect(_on_area_entered)

func _physics_process(delta):
	if is_transitioning:
		transition_progress += delta / transition_duration
		if transition_progress >= 1.0:
			_finish_transition()
		else:
			_update_player_position(delta)
	if cooldown_timer > 0:
		cooldown_timer -= delta

func _on_area_entered(area: Area3D):
	var player_node: Player = find_player_node(area)
	if player_node == player and not is_any_elevator_active and cooldown_timer <= 0:
		start_transition()

func find_player_node(node: Node) -> CharacterBody3D:
	var current_node: Node = node
	while current_node:
		if current_node is CharacterBody3D:
			return current_node
		current_node = current_node.get_parent()
	return null

func start_transition():
	is_transitioning = true
	is_any_elevator_active = true
	transition_progress = 0.0
	start_y_position = player.global_position.y
	is_upward_transport = target_y_position > start_y_position
	_modify_player_collisions()
	cooldown_timer = transition_duration + post_transport_ignore_time
	last_y_velocity = 0.0
	print("Starting vertical transition. Direction: ", "Up" if is_upward_transport else "Down")

func _update_player_position(delta):
	var previous_y: float = player.global_position.y
	var new_y_position: float = lerp(start_y_position, target_y_position, ease(transition_progress, 0.35))
	player.global_position.y = new_y_position
	last_y_velocity = (new_y_position - previous_y) / delta

func _finish_transition():
	is_transitioning = false
	is_any_elevator_active = false
	player.global_position.y = target_y_position
	
	if is_upward_transport and player_movement:
		player_movement.execute_jump()
		print("Executed jump at end of upward transport")
	else:
		player.velocity.y = 0
	
	print("Vertical transition finished. Final Y position: ", player.global_position.y)
	print("Final vertical velocity: ", player.velocity.y)
	
	get_tree().create_timer(post_transport_ignore_time).connect("timeout", _restore_player_collisions)

func _modify_player_collisions():
	original_collision_mask = player.collision_mask
	player.collision_mask = floor_collision_layer

func _restore_player_collisions():
	player.collision_mask = original_collision_mask
	print("Player collisions restored")
