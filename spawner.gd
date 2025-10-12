class_name Spawner
extends Area3D


@export var min_spawn_rate: float = 4.0
@export var max_spawn_rate: float = 7.0
@export var enemies: Array[PackedScene] = []

@export_group("Spawner Properties")
@export var initial_health: float = 70.0
@export var mesh_instances: Array[MeshInstance3D] = []

var spawn_time_left: float = 0.0

var health: float = initial_health:
	set(value):
		if value < health:
			apply_mat_override_to_mesh_instances(preload("res://Materials/enemy_hit_material.tres"))
			damage_effect_timer.start()
			if value <= 0.0 and health > 0.0:
				explode()
		health = value

static var total_spawner_count: int = 0

@onready var damage_effect_timer: Timer = Timer.new()


func _ready() -> void:
	Spawner.total_spawner_count += 1
	body_entered.connect(_on_body_entered)
	add_child(damage_effect_timer)
	damage_effect_timer.wait_time = 0.125
	damage_effect_timer.timeout.connect(apply_mat_override_to_mesh_instances.bind(null))

func _physics_process(delta: float) -> void:
	spawn_time_left -= delta
	if spawn_time_left <= 0.0:
		spawn_time_left += randf_range(min_spawn_rate, max_spawn_rate)
		var enemy: Node3D = enemies[randi_range(0, enemies.size() - 1)].instantiate()
		enemy.scale = Vector3.ONE * 0.0625
		get_tree().create_tween().tween_property(enemy, ^"scale", Vector3.ONE, 0.5).set_trans(Tween.TRANS_QUAD)
		enemy.position = position
		get_parent().add_child(enemy)
		$AnimationPlayer.play(&"spawn")

func take_damage(amount: float) -> void:
	health -= amount

func explode() -> void:
	Spawner.total_spawner_count -= 1
	GameGlobals.spawner_destroyed.emit()
	var explosion: Node3D = preload("res://Scenes/spawner_explosion.tscn").instantiate()
	explosion.position = position
	get_parent().add_child(explosion)
	queue_free()

func apply_mat_override_to_mesh_instances(material: Material) -> void:
	for mesh_instance: MeshInstance3D in mesh_instances:
		mesh_instance.material_override = material

func _on_body_entered(body: Node3D) -> void:
	if body is PlayerBullet:
		take_damage(body.damage)
		body.explode()
