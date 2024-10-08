extends Node

@onready var animation_bell: AnimationPlayer = $AnimationBell
@onready var animation_tongue: AnimationPlayer = $AnimationTongue

var credits_timer: Timer

func _ready() -> void:
	if (SceneManager.forest_visited and SceneManager.frozen_visited and SceneManager.sky_visited):
		await get_tree().create_timer(1).timeout
		animation_bell.play("bell")

		await get_tree().create_timer(0.1).timeout
		animation_tongue.play("tongue")

		credits_timer = Timer.new()
		credits_timer.one_shot = true
		credits_timer.timeout.connect(go_to_credits)
		add_child(credits_timer)
		credits_timer.start(20.0)

func go_to_credits() -> void:
	print("30 seconds passed. Transitioning to end credits.")
	get_tree().change_scene_to_file("res://scenes/end_credits.tscn")
