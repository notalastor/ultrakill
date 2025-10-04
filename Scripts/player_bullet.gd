class_name PlayerBullet
extends RigidBody3D


@export var damage: float = 10.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	if body is Enemy:
		body.take_damage(damage)
	explode()

func explode() -> void:
	queue_free()
