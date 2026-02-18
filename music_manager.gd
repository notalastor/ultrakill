extends Node


@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer


func play_music(stream: AudioStream, volume_db: float = -16.0) -> void:
	if !audio_stream_player.playing or audio_stream_player.stream != stream:
		audio_stream_player.stream = stream
		audio_stream_player.volume_db = volume_db
		audio_stream_player.play()

func stop_music() -> void:
	audio_stream_player.stop()

func play_main_menu_music() -> void:
	play_music(load("res://Sounds/God-forsaken sculpture.mp3"), -10.0)

func play_game_music() -> void:
	play_music(load("res://Sounds/A sinful impulse.mp3"), -16.0)
