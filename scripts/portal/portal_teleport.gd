"""
	Asset: Godot Simple Portal System
	File: portal.gd
	Description: An area which teleports the player through the parent node's portal.
	Instructions: For detailed documentation, see the README or visit: https://github.com/Donitzo/godot-simple-portal-system
	Repository: https://github.com/Donitzo/godot-simple-portal-system
	License: CC0 License
"""

extends Area3D
class_name PortalTeleport

var parent_portal: Portal

func _ready():
	parent_portal = get_parent() as Portal
	if parent_portal == null:
		push_error("The PortalTeleport \"%s\" is not a child of a Portal instance" % name)
	area_entered.connect(on_area_entered)

func on_area_entered(area: Area3D):
	if area.has_meta("teleportable_root"):
		var root: Node3D = area.get_node(area.get_meta("teleportable_root"))
		
		disable_boundaries()
		
		root.global_transform = parent_portal.real_to_exit_transform(root.global_transform)

func disable_boundaries():
	var boundaries_node = parent_portal.get_parent()
	if boundaries_node and boundaries_node.has_method("on_portal_hit"):
		boundaries_node.on_portal_hit()
	else:
		push_warning("Parent node doesn't have on_portal_hit method")
