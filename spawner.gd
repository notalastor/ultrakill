class_name Spawner
extends Area3D


@export var min_spawn_rate: float = 4.0
@export var max_spawn_rate: float = 7.0
@export var enemies: Array[PackedScene] = []

@export var health: float = 70.0

var spawn_time_left: float = 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	spawn_time_left -= delta
	if spawn_time_left <= 0.0:
		spawn_time_left += randf_range(min_spawn_rate, max_spawn_rate)
		var enemy: Node3D = enemies[randi_range(0, enemies.size() - 1)].instantiate()
		enemy.position = position
		get_parent().add_child(enemy)

func take_damage(amount: float) -> void:
	health -= amount
	if health <= 0.0:
		explode()

func explode() -> void:
	queue_free()
	
func _on_body_entered(body: Node3D) -> void:
	if body is PlayerBullet:
		take_damage(body.damage)
		body.explode()
