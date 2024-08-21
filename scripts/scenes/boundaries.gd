extends Node3D

#region NODES
@export var lower_boundary_node_path: NodePath
@export var upper_boundary_node_path: NodePath
@export var player_path: NodePath
@export var safe_spot_node: NodePath
#endregion


#region VARIABLES
@export var teleport_offset: float = 1.0
@export var max_lower_hits: int = 4
@export var lower_hits_limit: bool = false

var player: Player
var lower_boundary: Node3D
var upper_boundary: Node3D
var safe_spot: Node3D
var is_teleporting: bool = false
var lower_hit_counter: int = 0
#endregion


#region LIFECYCLE
func _ready():
	player = get_node(player_path)
	lower_boundary = get_node(lower_boundary_node_path)
	upper_boundary = get_node(upper_boundary_node_path)
	safe_spot = get_node(safe_spot_node)

	player.jump.connect("landed", Callable(self, "on_player_landed"))

	if not player:
		push_error("Player node not found!")
	if not lower_boundary:
		push_error("Lower boundary node not found!")
	if not upper_boundary:
		push_error("Upper boundary node not found!")
	if not safe_spot:
		push_error("Safe spot node not found!")

func _physics_process(_delta):
	if player and lower_boundary and upper_boundary and safe_spot and not is_teleporting:
		var player_pos: Vector3 = player.global_transform.origin
		var lower_y: float = lower_boundary.global_transform.origin.y
		var upper_y: float = upper_boundary.global_transform.origin.y

		if player_pos.y < lower_y:
			lower_hit_counter += 1
			if lower_hit_counter >= max_lower_hits and lower_hits_limit:
				safety_teleport()
			else:
				teleport_player(player_pos, upper_y + teleport_offset)
#endregion


#region TELEPORT
func teleport_player(current_pos: Vector3, new_y: float):
	is_teleporting = true
	player.velocity = Vector3.ZERO
	player.global_transform.origin = Vector3(current_pos.x, new_y, current_pos.z)

	await get_tree().create_timer(0.1).timeout
	is_teleporting = false

func safety_teleport():
	print("Safety teleport activated after ", lower_hit_counter, " lower boundary hits")
	player.velocity = Vector3.ZERO
	player.global_transform.origin = safe_spot.global_transform.origin
	lower_hit_counter = 0
#endregion


#region SIGNALS
func on_player_landed():
	print("Lower boundary hit count has been reset")
	lower_hit_counter = 0
#endregion
