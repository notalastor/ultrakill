extends Area3D


var active: bool:
	set(value):
		$MeshInstance3D.visible = value
		active = value

func _ready() -> void:
	active = false
	@warning_ignore("int_as_enum_without_cast")
	GameGlobals.spawner_destroyed.connect(func():
		print("Spawner count: ", Spawner.total_spawner_count)
		if Spawner.total_spawner_count <= 0:
			active = true
	)

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		if active:
			body.change_scene = true
			body.speed = 0
			body.SPRINT_SPEED = 0
			body.WALK_SPEED = 0
			body.SLIDE_SPEED = 0
			body.JUMP_VELOCITY = 0
			await get_tree().create_timer(2).timeout
			get_tree().change_scene_to_file("res://Scenes/World.tscn")
