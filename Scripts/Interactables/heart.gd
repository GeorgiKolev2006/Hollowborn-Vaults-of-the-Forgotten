extends Area2D

@export var health_amount: float = 1  # Allow fractional healing

func _ready():
	connect("body_entered", _on_body_entered)

func _on_body_entered(body):
	if body.has_method("increase_health") and Player_data.health < Player_data.max_health:
		body.increase_health(health_amount)
		queue_free()  # Remove heart after pickup
