extends Node3D

# boundaries.gd
## A script to manage boundary areas with teleportation functionality for the player.

#region EXPORTS
@export var player_path: NodePath ## Path to the player node
@export var teleport_offset_y: float = 0.1 ## Vertical offset when teleporting
@export var teleport_offset_x: float = 0.1 ## Horizontal X offset when teleporting
@export var teleport_offset_z: float = 0.1 ## Horizontal Z offset when teleporting
@export var portal_cooldown: float = 1.0 ## Cooldown time after using a portal
@export var is_initial_area: bool = false ## Whether this is the initial spawn area
#endregion


#region VARIABLES
var player: Player ## Reference to the player node
var is_teleporting: bool = false ## Flag to prevent multiple teleports
var level_bounds: AABB ## Bounding box of the current level area
var boundaries_disabled: bool = false ## Flag to disable boundaries temporarily
var portal_timer: float = 0.0 ## Timer for portal cooldown
var is_active: bool = false ## Flag to indicate if this boundary is currently active
#endregion


#region LIFECYCLE METHODS
func _ready():
	## Initialize the boundary area
	player = get_node(player_path)
	if not player:
		push_error("Player node not found!")
	level_bounds = calculate_spatial_bounds(self, true)
	
	if is_initial_area:
		call_deferred("on_portal_hit")

func _physics_process(delta):
	## Handle boundary checks and portal cooldown
	if player and is_active:
		if boundaries_disabled:
			portal_timer -= delta
			if portal_timer <= 0:
				boundaries_disabled = false
		elif not is_teleporting:
			check_and_teleport_player()
#endregion


#region BOUNDARY MANAGEMENT
func check_and_teleport_player():
	## Check if the player is out of bounds and teleport if necessary
	var player_pos: Vector3 = player.global_transform.origin
	var lower_y: float = global_transform.origin.y + level_bounds.position.y
	var upper_y: float = lower_y + level_bounds.size.y
	var left_x: float = global_transform.origin.x + level_bounds.position.x
	var right_x: float = left_x + level_bounds.size.x
	var back_z: float = global_transform.origin.z + level_bounds.position.z
	var front_z: float = back_z + level_bounds.size.z
	
	var new_pos: Vector3 = player_pos
	var teleport_needed: bool = false
	
	# Check Y bounds
	if player_pos.y < lower_y:
		new_pos.y = upper_y - teleport_offset_y
		teleport_needed = true
	elif player_pos.y > upper_y:
		new_pos.y = lower_y + teleport_offset_y
		teleport_needed = true
	
	# Check X bounds
	if player_pos.x < left_x:
		new_pos.x = right_x - teleport_offset_x
		new_pos.y = player_pos.y
		teleport_needed = true
	elif player_pos.x > right_x:
		new_pos.x = left_x + teleport_offset_x
		new_pos.y = player_pos.y
		teleport_needed = true
	
	# Check Z bounds
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
	## Teleport the player to a new position
	is_teleporting = true
	var current_velocity: Vector3 = player.velocity
	player.global_transform.origin = new_pos
	player.velocity = current_velocity
	await get_tree().create_timer(0.1).timeout
	is_teleporting = false

func calculate_spatial_bounds(parent: Node, exclude_top_level_transform: bool) -> AABB:
	## Calculate the bounding box of the level area
	var bounds: AABB = AABB()
	if parent is VisualInstance3D:
		bounds = parent.get_aabb()
	for i in range(parent.get_child_count()):
		var child: Node = parent.get_child(i)
		if child is Node3D:
			var child_bounds: AABB = calculate_spatial_bounds(child, false)
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


#region PORTAL INTERACTIONS
func disable_boundaries():
	## Temporarily disable boundaries after using a portal
	boundaries_disabled = true
	portal_timer = portal_cooldown

func on_portal_hit():
	## Activate this boundary area when entering through a portal
	is_active = true
	disable_boundaries()

func deactivate():
	## Deactivate this boundary area when leaving through a portal
	is_active = false
#endregion
