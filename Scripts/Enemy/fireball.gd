extends Area2D

@export var speed: float = 250
var direction: Vector2 = Vector2.ZERO
var can_collide: bool = false

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	rotation = direction.angle()

	# Slight spawn offset
	position += direction * 8

	# Wait a frame before enabling collision (prevents self-hit)
	await get_tree().create_timer(0.05).timeout
	can_collide = true

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if not can_collide:
		return

	if body.is_in_group("Player"):
		if body.has_method("take_damage"):
			body.take_damage(Vector2.ZERO)
		queue_free()
	else:
		# This catches walls (TileMap) via layer collision
		queue_free()
