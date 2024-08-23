extends Node3D
class_name MirrorObject

@export var portal: Portal

@export var ray_scene: PackedScene

var mirrored_object: Node3D

@export var max_distance: float = 100.0

var current_length: float = 0.0

var object_instance: Node3D

func _ready():
	if ray_scene:
		object_instance = ray_scene.instantiate()
		add_child(object_instance)

		mirrored_object = ray_scene.instantiate()
		mirrored_object.name = "MirroredObject"
		add_child(mirrored_object)
	else:
		push_error("Mirrored object scnee scene is not set. Please assign a scene in the Inspector.")

func _process(_delta) -> void:
	if not object_instance or not mirrored_object:
		return

	if portal:
		mirrored_object.global_transform = portal.real_to_exit_transform(global_transform)

		var distance_to_portal: float = global_position.distance_to(portal.global_position)

		if distance_to_portal < max_distance:
			current_length = distance_to_portal

			var mirrored_length: float = max_distance - distance_to_portal
			mirrored_object.scale.z = mirrored_length / max_distance
			mirrored_object.visible = true
		else:
			current_length = max_distance
			mirrored_object.visible = false
	else:
		current_length = max_distance
		mirrored_object.visible = false

	object_instance.scale.z = current_length / max_distance

func set_portal(new_portal: Portal):
	portal = new_portal

func get_end_point() -> Vector3:
	return global_transform.origin + global_transform.basis.z * current_length

func get_mirrored_end_point() -> Vector3:
	if mirrored_object.visible:
		return mirrored_object.global_transform.origin + mirrored_object.global_transform.basis.z * (mirrored_object.scale.z * max_distance)
	else:
		return Vector3.ZERO
