extends Node3D

@export var speed: int = 15
@onready var fireball: MeshInstance3D = $ball/fireball
@export var force: float = 30.0 ##قوة/ بعد الضربة 
@export var knock_time: float = 0.2 ##المدة اللازمه لتوقف تأثير الضربه
func _process(delta: float) -> void:
	position += transform.basis * Vector3(0,0,-speed) * delta
	fireball.rotation.z += delta * speed


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		var knock_dir = (body.global_position - global_position).normalized()
		knock_dir.y /= 2
		body.knock_back(knock_dir,force,knock_time)
		body.take_damage(20)
		queue_free()
	else:
		if not body is CharacterBody3D:
			queue_free()
