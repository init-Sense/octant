extends Node3D

@export var lower_boundary_node: NodePath
@export var upper_boundary_node: NodePath
@export var player_path: NodePath

var player: Player
var lower_boundary: Node3D
var upper_boundary: Node3D

func _ready():
	player = get_node(player_path)
	lower_boundary = get_node(lower_boundary_node)
	upper_boundary = get_node(upper_boundary_node)

	if not player:
		push_error("Player node not found!")
	if not lower_boundary:
		push_error("Lower boundary node not found!")
	if not upper_boundary:
		push_error("Upper boundary node not found!")

func _process(_delta):
	if player and lower_boundary and upper_boundary:
		var player_pos: Vector3 = player.global_transform.origin
		if player_pos.y < lower_boundary.global_transform.origin.y:
			player.global_transform.origin = Vector3(player_pos.x, upper_boundary.global_transform.origin.y, player_pos.z)
		elif player_pos.y > upper_boundary.global_transform.origin.y:
			player.global_transform.origin = Vector3(player_pos.x, lower_boundary.global_transform.origin.y, player_pos.z)
