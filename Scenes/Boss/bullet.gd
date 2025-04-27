extends Area2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var despawn_timer = $Timer  # Make sure you have a Timer node set

var player: Node2D = null
var acceleration: Vector2 = Vector2.ZERO 
var velocity: Vector2 = Vector2.ZERO

func _ready():
	player = get_tree().get_root().find_child("Player", true, false)
	despawn_timer.start(3.0)
	connect("body_entered", Callable(self, "_on_body_entered"))
	despawn_timer.connect("timeout", Callable(self, "_on_despawn_timeout"))

func _physics_process(delta):
	if player == null:
		return

	acceleration = (player.position - position).normalized() * 700
	velocity += acceleration * delta
	rotation = velocity.angle()
	velocity = velocity.limit_length(150)
	position += velocity * delta

func _on_body_entered(body):
	if body.is_in_group("Player") and body.has_method("take_damage"):
		body.take_damage(velocity)
	queue_free()

func _on_despawn_timeout():
	queue_free()
