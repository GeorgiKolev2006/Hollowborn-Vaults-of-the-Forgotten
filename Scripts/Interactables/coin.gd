extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_data.coin += 1
		print(player_data.coin)
		print("your life is equal to", player_data.health)
		queue_free()
