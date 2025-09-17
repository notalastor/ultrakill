class_name Powerup
extends Area3D


func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		collect(body)

func collect(player: Player) -> void:
	_on_collected(player)
	queue_free()


func _on_collected(_player: Player) -> void:
	pass
