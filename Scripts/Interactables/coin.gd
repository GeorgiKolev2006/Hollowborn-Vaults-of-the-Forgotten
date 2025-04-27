extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		PlayerData.coin += 1
		PlayerData.score += 10
		queue_free()
