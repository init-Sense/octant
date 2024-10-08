# end_credits.gd
extends Node

# Timer to track when to return to the title screen
var return_timer: Timer

func _ready():
	# Create and configure the timer
	return_timer = Timer.new()
	return_timer.one_shot = true
	return_timer.timeout.connect(go_to_title_screen)
	add_child(return_timer)
	
	# Start the 30-second timer
	return_timer.start(5.0)
	
	print("End credits started. Returning to title screen in 30 seconds.")

func go_to_title_screen():
	print("End credits finished. Returning to title screen.")
	# Transition to the title screen
	SceneManager.reset_all()
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")
