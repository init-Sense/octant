extends Node


@onready var animation_bell: AnimationPlayer = $AnimationBell
@onready var animation_tongue: AnimationPlayer = $AnimationTongue


func _ready() -> void:
	await get_tree().create_timer(1).timeout
	animation_bell.play("bell")
	
	await get_tree().create_timer(0.1).timeout
	animation_tongue.play("tongue")
