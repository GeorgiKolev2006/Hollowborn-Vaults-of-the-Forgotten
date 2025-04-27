extends Area2D

@export var speed: float = 100
@export var life_time: float = 2.0
@export var turn_speed: float = 3.0  # Controls how strongly it curves
var direction: Vector2 = Vector2.ZERO
var target: Node2D = null
var can_collide: bool = false

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

	# Small spawn offset to avoid hitting sender
	position += direction.normalized() * 8
	rotation = direction.angle()

	await get_tree().create_timer(0.05).timeout
	can_collide = true

	await get_tree().create_timer(life_time).timeout
	queue_free()

func _physics_process(delta):
	if target and is_instance_valid(target):
		var desired_dir = (target.global_position - global_position).normalized()
		var angle_diff = direction.angle_to(desired_dir)
		direction = direction.rotated(angle_diff * turn_speed * delta).normalized()
		rotation = direction.angle()

	position += direction * speed * delta

func _on_body_entered(body):
	if not can_collide:
		return

	if body.is_in_group("Player") and body.has_method("take_damage"):
		body.take_damage(Vector2.ZERO)
		queue_free()
	else:
		queue_free()
