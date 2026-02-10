extends Control


func resume() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false
	queue_free()

func settings() -> void:
	var settings: Node = load("res://Scenes/settings.tscn").instantiate()
	settings.as_instance = true
	add_child(settings)

func back_to_main_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func _on_settings_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/settings.tscn")
