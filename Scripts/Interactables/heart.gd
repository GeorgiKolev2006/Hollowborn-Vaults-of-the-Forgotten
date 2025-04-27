extends Area2D

@export var health_amount: float = 1.0  # Allow fractional healing

func _ready():
	connect("body_entered", _on_body_entered)

func _on_body_entered(body):
	if body.has_method("increase_health") and PlayerData.health < PlayerData.max_health:
		body.increase_health(health_amount)
		queue_free()  # Remove heart after pickup
