class_name Enemy
extends CharacterBody3D

@export var initial_health: float = 50.0

var health: float = initial_health:
	set(value):
		health = value
		if value <= 0.0:
			die()

func take_damage(amount: float) -> void:
	health -= amount

func die() -> void:
	queue_free()
