# boundaries.gd
#
# This script implements a spatial wrapping mechanism for a player character
# within a defined 3D space. When the player crosses the boundaries of this space,
# they are teleported to the opposite side, creating a wrap-around effect.
#
# Key Components:
# - Boundary Calculation: Determines the 3D bounds of the wrap area
# - Player Tracking: Monitors the player's position relative to the boundaries
# - Teleportation: Moves the player to the opposite boundary when they cross an edge
# - Velocity Preservation: Maintains the player's velocity through teleportation
#
# Usage:
# 1. Attach this script to a Node3D that defines the wrap area.
# 2. Set the player_path export variable to reference the player node.
# 3. Adjust the teleport_offset if needed to fine-tune the teleportation position.
#
# Note: This script assumes the player is a CharacterBody3D and has a velocity property.

extends Node3D

#region NODES
@export var player_path: NodePath
#endregion


#region VARIABLES
@export var teleport_offset_y: float = 0.01
@export var teleport_offset_x: float = 0.5
@export var teleport_offset_z: float = 0.5
var player: CharacterBody3D
var is_teleporting: bool = false
var level_bounds: AABB
#endregion


#region LIFECYCLE
func _ready():
	player = get_node(player_path)
	if not player:
		push_error("Player node not found!")
	level_bounds = _calculate_spatial_bounds(self, true)


func _physics_process(_delta):
	if player and not is_teleporting:
		check_and_teleport_player()
#endregion


#region TELEPORT
func check_and_teleport_player():
	var player_pos: Vector3 = player.global_transform.origin
	var lower_y: float = global_transform.origin.y + level_bounds.position.y
	var upper_y: float = lower_y + level_bounds.size.y
	var left_x: float = global_transform.origin.x + level_bounds.position.x
	var right_x: float = left_x + level_bounds.size.x
	var back_z: float = global_transform.origin.z + level_bounds.position.z
	var front_z: float = back_z + level_bounds.size.z

	var new_pos: Vector3 = player_pos
	var teleport_needed: bool = false

	if player_pos.y < lower_y:
		new_pos.y = upper_y - teleport_offset_y
		teleport_needed = true
	elif player_pos.y > upper_y:
		new_pos.y = lower_y + teleport_offset_y
		teleport_needed = true

	if player_pos.x < left_x:
		new_pos.x = right_x - teleport_offset_x
		new_pos.y = player_pos.y
		teleport_needed = true
	elif player_pos.x > right_x:
		new_pos.x = left_x + teleport_offset_x
		new_pos.y = player_pos.y
		teleport_needed = true

	if player_pos.z < back_z:
		new_pos.z = front_z - teleport_offset_z
		new_pos.y = player_pos.y
		teleport_needed = true
	elif player_pos.z > front_z:
		new_pos.z = back_z + teleport_offset_z
		new_pos.y = player_pos.y
		teleport_needed = true

	if teleport_needed:
		teleport_player(new_pos)


func teleport_player(new_pos: Vector3):
	is_teleporting = true
	var current_velocity: Vector3 = player.velocity
	player.global_transform.origin = new_pos
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
