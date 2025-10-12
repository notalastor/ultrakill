extends Powerup

func _on_collected(player: Player) -> void:
	player.add_max_ammo(15)
