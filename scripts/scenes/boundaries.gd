extends Node3D

#region NODES
@export var player_path: NodePath
#endregion


#region VARIABLES
@export var teleport_offset: float = 1.0
var player: CharacterBody3D
var is_teleporting: bool = false
var bounds: AABB
#endregion


#region LIFECYCLE
func _ready():
	player = get_node(player_path)
	if not player:
		push_error("Player node not found!")

	bounds = _calculate_spatial_bounds(self, true)

func _physics_process(_delta):
	if player and not is_teleporting:
		var player_pos: Vector3 = player.global_transform.origin
		var lower_y: float = global_transform.origin.y + bounds.position.y
		var upper_y: float = lower_y + bounds.size.y

		if player_pos.y < lower_y:
			teleport_player(player_pos, upper_y + teleport_offset)
		elif player_pos.y > upper_y:
			teleport_player(player_pos, lower_y + teleport_offset)
#endregion


#region TELEPORT
func teleport_player(current_pos: Vector3, new_y: float):
	is_teleporting = true
	var current_velocity: Vector3 = player.velocity
	player.global_transform.origin = Vector3(current_pos.x, new_y, current_pos.z)
	player.velocity = current_velocity
	await get_tree().create_timer(0.1).timeout
	is_teleporting = false
#endregion


#region BOUNDS CALCULATION
func _calculate_spatial_bounds(parent: Node, exclude_top_level_transform: bool) -> AABB:
	var bounds: AABB = AABB()
	if parent is VisualInstance3D:
		bounds = parent.get_aabb()

	for i in range(parent.get_child_count()):
		var child: Node = parent.get_child(i)
		if child is Node3D:
			var child_bounds: AABB = _calculate_spatial_bounds(child, false)
			if bounds.size == Vector3.ZERO and parent is Node3D:
				bounds = child_bounds
			else:
				bounds = bounds.merge(child_bounds)

	if bounds.size == Vector3.ZERO and parent is Node3D:
		bounds = AABB(Vector3(-0.2, -0.2, -0.2), Vector3(0.4, 0.4, 0.4))

	if not exclude_top_level_transform and parent is Node3D:
		bounds = parent.transform * bounds

	return bounds
#endregion
