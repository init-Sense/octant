extends Area3D
class_name EnvironmentArea

@export var is_zero_g: bool = false
@export var is_slippery: bool = false
@export var gravity_modifier: float = 0.0
@export var player_path: NodePath

var player: Player
var player_movement: Movement

func _ready():
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	
	if not player_path.is_empty():
		player = get_node(player_path)
		if player:
			player_movement = player.get_node("Modules/Movement")
	else:
		push_warning("Player path not set in EnvironmentArea: " + name)

func _on_area_entered(area: Area3D):
	var player_node = find_player_node(area)
	if player_node:
		player = player_node
		player_movement = player.get_node("Modules/Movement")
		apply_environment()

func _on_area_exited(area: Area3D):
	var player_node = find_player_node(area)
	if player_node == player:
		reset_environment()

func find_player_node(node: Node) -> Player:
	var current_node = node
	while current_node:
		if current_node is Player:
			return current_node
		current_node = current_node.get_parent()
	return null

func apply_environment():
	if player_movement:
		player_movement.is_zero_g = is_zero_g
		player_movement.slippery = is_slippery
		
		if is_zero_g:
			player_movement.gravity.set_gravity(0.0)
		else:
			var applied_gravity = Gravity.DEFAULT_GRAVITY
			if gravity_modifier != 0.0:
				applied_gravity = gravity_modifier
			player_movement.gravity.set_gravity(applied_gravity)
		
		print("Applied environment: Zero-G =", is_zero_g, ", Slippery =", is_slippery, ", Gravity =", player_movement.gravity.current_gravity)
	else:
		push_warning("Player movement not found in EnvironmentArea: " + name)

func reset_environment():
	if player_movement:
		player_movement.is_zero_g = false
		player_movement.slippery = false
		player_movement.gravity.set_gravity(Gravity.DEFAULT_GRAVITY)
		print("Reset environment to default")
	else:
		push_warning("Player movement not found in EnvironmentArea: " + name)
