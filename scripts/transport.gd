extends Area3D
class_name Transport

@export var player_path: NodePath
@export var target_position_node: NodePath
@export var transition_duration: float = 1.0
@export var recovery_time: float = 1.0
@export var post_transport_ignore_time: float = 0.5
@export_flags_3d_physics var floor_collision_layer: int = 1

@onready var player: CharacterBody3D = get_node(player_path)
@onready var target_position: Vector3 = get_node(target_position_node).global_position

var is_transitioning: bool = false
var transition_progress: float = 0.0
var start_position: Vector3
var original_collision_mask: int

static var global_cooldown_timer: float = 0.0
static var is_any_elevator_active: bool = false

func _ready():
	area_entered.connect(_on_area_entered)

func _physics_process(delta):
	if is_transitioning:
		transition_progress += delta / transition_duration
		if transition_progress >= 1.0:
			_finish_transition()
		else:
			_update_player_position()
	
	# Update global cooldown
	if global_cooldown_timer > 0:
		global_cooldown_timer -= delta
		if global_cooldown_timer <= 0:
			is_any_elevator_active = false

func _on_area_entered(area: Area3D):
	var player_node = find_player_node(area)
	if player_node == player and not is_any_elevator_active and global_cooldown_timer <= 0:
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
	is_any_elevator_active = true
	transition_progress = 0.0
	start_position = player.global_position
	player.set_physics_process(false)
	_modify_player_collisions()
	global_cooldown_timer = transition_duration + post_transport_ignore_time + recovery_time
	print("Starting elevator transition")

func _update_player_position():
	var new_position = start_position.lerp(target_position, ease(transition_progress, 0.5))
	player.global_position = new_position

func _finish_transition():
	is_transitioning = false
	player.global_position = target_position
	player.velocity = Vector3.ZERO
	player.set_physics_process(true)
	print("Elevator transition finished. Final position: ", player.global_position)
	
	get_tree().create_timer(post_transport_ignore_time).connect("timeout", _restore_player_collisions)

func _modify_player_collisions():
	original_collision_mask = player.collision_mask
	player.collision_mask = floor_collision_layer

func _restore_player_collisions():
	player.collision_mask = original_collision_mask
	print("Player collisions restored")
