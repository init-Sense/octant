extends Node3D

@onready var shell_animation = $ShellAnimation


func _ready():
	await get_tree().create_timer(2).timeout 
	shell_animation.play("opening")
	pass # Replace with function body.
