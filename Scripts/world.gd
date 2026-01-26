extends Node3D


func _enter_tree() -> void:
	Spawner.total_spawner_count = 0


func _ready() -> void:
	MusicManager.play_game_music()
