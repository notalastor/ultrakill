extends Powerup


func _on_collected(player: Player) -> void:
	player.health += 30.0
