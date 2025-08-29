extends Area3D

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		body.change_scene = true
		body.speed = 0
		body.SPRINT_SPEED = 0
		body.WALK_SPEED = 0
		body.SLIDE_SPEED = 0
		body.JUMP_VELOCITY = 0
		await get_tree().create_timer(2).timeout
		get_tree().change_scene_to_file("res://Scenes/World.tscn")
