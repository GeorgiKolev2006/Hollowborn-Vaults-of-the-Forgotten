extends Node2D

@export var health := 2
@export var snake_bullet_scene: PackedScene  # Drag in your homing snake projectile
@export var shoot_interval := 2.0

var player: Node2D = null
var is_shooting := false

@onready var animation_player := $AnimationPlayer
@onready var hit_sprite := $AnimatedSprite2D 

func _ready():
	$Monitoring.connect("body_entered", Callable(self, "_on_monitoring_body_entered"))
	$Monitoring.connect("body_exited", Callable(self, "_on_monitoring_body_exited"))
	animation_player.play("idle")

func _on_monitoring_body_entered(body):
	if body.is_in_group("Player"):
		player = body
		start_shooting()

func _on_monitoring_body_exited(body):
	if body == player:
		player = null
		is_shooting = false
		animation_player.play("idle")

func start_shooting():
	if is_shooting or player == null:
		return
	is_shooting = true
	shoot_loop()

func shoot_loop():
	while player and health > 0:
		animation_player.play("shoot")
		await get_tree().create_timer(shoot_interval).timeout
	is_shooting = false
	if health > 0:
		animation_player.play("idle")

func shoot_snake_bullet():
	if not player or not is_instance_valid(player):
		return
	var bullet = snake_bullet_scene.instantiate()
	bullet.global_position = global_position
	bullet.target = player
	bullet.direction = (player.global_position - global_position).normalized()
	get_tree().current_scene.add_child(bullet)

func take_damage(_vel: Vector2):
	health -= 1
	flash()
	if health <= 0:
		die()

func die():
	animation_player.play("dead")
	await get_tree().create_timer(1.0).timeout
	queue_free()

func flash():
	var mat := $Sprite2D.material as ShaderMaterial
	mat.set_shader_parameter("flash_modifier", 1.0)
	await get_tree().create_timer(0.2).timeout
	mat.set_shader_parameter("flash_modifier", 0.0)

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Sword") or area.name == "Player/sword":
		take_damage(Vector2.ZERO)
