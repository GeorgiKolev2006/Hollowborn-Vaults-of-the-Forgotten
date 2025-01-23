extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_data.coin += 1
		PlayerData.score += 10
		PlayerData.save_to_firebase()
		queue_free()
