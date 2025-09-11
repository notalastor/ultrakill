class_name Enemy
extends CharacterBody3D

@export var mesh_instances: Array[MeshInstance3D] = []
@onready var damage_effect_timer: Timer = Timer.new()
@export var initial_health: float = 50.0

var health: float = initial_health:
	set(value):
		if value < health:
			damage_taken.emit(health - value)
		health = value
		if value <= 0.0:
			die()
signal damage_taken(amount: float)



func _ready() -> void:
	damage_effect_timer.wait_time = 0.125
	add_child(damage_effect_timer)
	damage_effect_timer.timeout.connect(apply_mat_override_to_mesh_instances.bind(null))
	damage_taken.connect((func():
		apply_mat_override_to_mesh_instances(preload("res://Materials/enemy_hit_material.tres"))
		damage_effect_timer.start()
	).unbind(1))

func apply_mat_override_to_mesh_instances(material: Material) -> void:
	for mesh_instance: MeshInstance3D in mesh_instances:
		mesh_instance.material_override = material
		print(mesh_instance)
		print(mesh_instance.material_override)

func take_damage(amount: float) -> void:
	health -= amount

func die() -> void:
	queue_free()
