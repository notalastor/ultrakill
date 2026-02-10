extends Node3D

var as_instance: bool

func _ready() -> void:
	%MusicSlider.value = SaveManager.music_volume
	%SFXSlider.value = SaveManager.sfx_volume

# Back Button Function
func BackButton_Pressed() -> void:
	SaveManager.save_config_file()
	if as_instance:
		queue_free()
	else:
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func _on_music_slider_value_changed(value: float) -> void:
	SaveManager.music_volume = value


func _on_sfx_slider_value_changed(value: float) -> void:
	SaveManager.sfx_volume = value
