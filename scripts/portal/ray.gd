extends Node3D
class_name Ray

# The portal that this ray interacts with
@export var portal: Portal

# The scene to use for the ray visualization
@export var ray_scene: PackedScene

# The mirrored ray on the other side of the portal
var mirrored_ray: Node3D

# The maximum distance the ray can travel
@export var max_distance: float = 100.0

# The current length of the ray
var current_length: float = 0.0

# The instance of the ray scene
var ray_instance: Node3D

func _ready():
	if ray_scene:
		ray_instance = ray_scene.instantiate()
		add_child(ray_instance)

		mirrored_ray = ray_scene.instantiate()
		mirrored_ray.name = "MirroredRay"
		add_child(mirrored_ray)
	else:
		push_error("Ray scene is not set. Please assign a scene in the Inspector.")

func _process(_delta) -> void:
	if not ray_instance or not mirrored_ray:
		return

	if portal:
		mirrored_ray.global_transform = portal.real_to_exit_transform(global_transform)

		var distance_to_portal: float = global_position.distance_to(portal.global_position)

		if distance_to_portal < max_distance:
			current_length = distance_to_portal

			var mirrored_length: float = max_distance - distance_to_portal
			mirrored_ray.scale.z = mirrored_length / max_distance
			mirrored_ray.visible = true
		else:
			current_length = max_distance
			mirrored_ray.visible = false
	else:
		current_length = max_distance
		mirrored_ray.visible = false

	ray_instance.scale.z = current_length / max_distance

func set_portal(new_portal: Portal):
	portal = new_portal

func get_end_point() -> Vector3:
	return global_transform.origin + global_transform.basis.z * current_length

func get_mirrored_end_point() -> Vector3:
	if mirrored_ray.visible:
		return mirrored_ray.global_transform.origin + mirrored_ray.global_transform.basis.z * (mirrored_ray.scale.z * max_distance)
	else:
		return Vector3.ZERO
