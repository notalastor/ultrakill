extends Node3D



# Called when the node enters the scene tree for the first time.
func button_play() -> void:
	get_tree().change_scene_to_file("res://Scenes/World.tscn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func button_settings() -> void:
	get_tree().change_scene_to_file("res://Scenes/settings.tscn")


func button_exit() -> void:
	get_tree().quit()
