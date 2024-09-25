extends Area3D
class_name EnvironmentArea

@export var is_zero_g: bool = false
@export var is_slippery: bool = false
@export var is_underwater: bool = false
@export var has_vignette: bool = false
@export var has_directional_light: bool = true

@export var gravity_override: float = 0.0
@export var player_path: NodePath

@export var world_environment_node: NodePath
@export var target_environment: Environment
@export var directional_light_node: NodePath

var player: Player
var player_movement: Movement

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	
	if not player_path.is_empty():
		player = get_node(player_path)
		if player:
			player_movement = player.get_node("Modules/Movement")
	else:
		push_warning("Player path not set in EnvironmentArea: " + name)


func _on_area_entered(area: Area3D) -> void:
	var player_node = find_player_node(area)
	if player_node:
		player = player_node
		player_movement = player.get_node("Modules/Movement")
		apply_gravity_and_slippery()
		apply_target_environment()
		show_directional_light()
		apply_underwater_post_processing()
		apply_vignette_post_processing()
		print("entered!!")


func _on_area_exited(area: Area3D) -> void:
	var player_node = find_player_node(area)
	if player_node == player:
		reset_gravity_and_slippery()
		hide_directional_light()


func find_player_node(node: Node) -> Player:
	var current_node = node
	while current_node:
		if current_node is Player:
			return current_node
		current_node = current_node.get_parent()
	return null


func apply_gravity_and_slippery() -> void:
	if player_movement:
		player_movement.is_zero_g = is_zero_g
		player_movement.slippery = is_slippery
		
		if is_zero_g:
			player_movement.gravity.set_gravity(0.0)
		else:
			var applied_gravity = Gravity.DEFAULT_GRAVITY
			if gravity_override != 0.0:
				applied_gravity = gravity_override
			player_movement.gravity.set_gravity(applied_gravity)
		
		print("Applied environment: Zero-G =", is_zero_g, ", Slippery =", is_slippery, ", Gravity =", player_movement.gravity.current_gravity)
	else:
		push_warning("Player movement not found in EnvironmentArea: " + name)


func apply_target_environment() -> void:
	var world_environment = get_node(world_environment_node)
	world_environment.environment = target_environment
	print("Environment disabled")


func apply_underwater_post_processing() -> void:
	var underwater_post_processing = player.get_node("Head/CameraSmooth/Camera/PostProcessing/UnderwaterCanvas")
	if is_underwater:
		underwater_post_processing.show()
		print("underwater visible")
	else:
		underwater_post_processing.hide()
		print("underwater not visible")


func apply_vignette_post_processing() -> void:
	var vignette_post_processing = player.get_node("Head/CameraSmooth/Camera/PostProcessing/VignetteCanvas")
	if has_vignette:
		vignette_post_processing.show()
	else:
		vignette_post_processing.hide()


func show_directional_light() -> void:
	if has_directional_light:
		var directional_light: DirectionalLight3D
		directional_light = get_node(directional_light_node)
		directional_light.show()

func hide_directional_light() -> void:
	if has_directional_light:
		var directional_light: DirectionalLight3D
		directional_light = get_node(directional_light_node)
		directional_light.hide()


func reset_gravity_and_slippery() -> void:
	if player_movement:
		player_movement.is_zero_g = false
		player_movement.slippery = false
		player_movement.gravity.set_gravity(Gravity.DEFAULT_GRAVITY)
		print("Reset environment to default")
	else:
		push_warning("Player movement not found in EnvironmentArea: " + name)
