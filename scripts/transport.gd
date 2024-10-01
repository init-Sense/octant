extends Area3D
class_name Transport

@export var target_position_node: NodePath
@export var transition_duration: float = 1.0
@export var post_transport_ignore_time: float = 5.0
@export_flags_3d_physics var floor_collision_layer: int = 1

var player: CharacterBody3D
var player_jump: Jump
@onready var target_y_position: float = get_node(target_position_node).global_position.y
var is_transitioning: bool = false
var transition_progress: float = 0.0
var start_y_position: float
var original_collision_mask: int
var last_y_velocity: float = 0.0
var is_upward_transport: bool = false
static var is_any_transport_active: bool = false
static var cooldown_timer: float = 0.0

func _ready():
	area_entered.connect(_on_area_entered)
	
	player = get_tree().get_first_node_in_group("player")
	if player:
		player_jump = player.get_node("Modules/Jump") if player.has_node("Modules/Jump") else null
	else:
		push_error("Player node not found in the scene")

func _physics_process(delta):
	if is_transitioning:
		transition_progress += delta / transition_duration
		if transition_progress >= 1.0:
			finish_transition()
		else:
			update_player_position(delta)
	if cooldown_timer > 0:
		cooldown_timer -= delta

func _on_area_entered(area: Area3D):
	var player_node: CharacterBody3D = find_player_node(area)
	if player_node == player and not is_any_transport_active and cooldown_timer <= 0:
		start_transition()

func find_player_node(node: Node) -> CharacterBody3D:
	var current_node: Node = node
	while current_node:
		if current_node is CharacterBody3D and current_node.is_in_group("player"):
			return current_node
		current_node = current_node.get_parent()
	return null

func start_transition():
	is_transitioning = true
	is_any_transport_active = true
	transition_progress = 0.0
	start_y_position = player.global_position.y
	is_upward_transport = target_y_position > start_y_position
	modify_player_collisions()
	cooldown_timer = transition_duration + post_transport_ignore_time
	last_y_velocity = 0.0
	print("Starting vertical transition. Direction: ", "Up" if is_upward_transport else "Down")

func update_player_position(delta):
	var previous_y: float = player.global_position.y
	var new_y_position: float = lerp(start_y_position, target_y_position, ease(transition_progress, 0.35))
	player.global_position.y = new_y_position
	last_y_velocity = (new_y_position - previous_y) / delta

func finish_transition():
	is_transitioning = false
	is_any_transport_active = false
	player.global_position.y = target_y_position
	
	if is_upward_transport and player_jump:
		player_jump.execute_jump()
		print("Applied vertical boost at end of upward transport")
	else:
		player.velocity.y = 0
	
	print("Vertical transition finished. Final Y position: ", player.global_position.y)
	print("Final vertical velocity: ", player.velocity.y)
	
	get_tree().create_timer(post_transport_ignore_time).timeout.connect(restore_player_collisions)

func modify_player_collisions():
	original_collision_mask = player.collision_mask
	player.collision_mask = floor_collision_layer

func restore_player_collisions():
	player.collision_mask = original_collision_mask
	print("Player collisions restored")
