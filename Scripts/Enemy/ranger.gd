extends Node2D

@export var health := 2
@export var fireball_scene: PackedScene
@export var shoot_interval := 2.0

var player: Node2D = null
var is_shooting := false

func _ready():
	$Monitoring.connect("body_entered", Callable(self, "_on_monitoring_body_entered"))
	$Monitoring.connect("body_exited", Callable(self, "_on_monitoring_body_exited"))
	$AnimationPlayer.play("idle")

func _on_monitoring_body_entered(body):
	if body.is_in_group("Player"):
		print("Player entered range!")
		player = body
		start_shooting()

func _on_monitoring_body_exited(body):
	if body == player:
		print("Player left range!")
		player = null
		is_shooting = false
		$AnimationPlayer.play("idle")

func start_shooting():
	if is_shooting or player == null:
		return
	is_shooting = true
	shoot_loop()

func shoot_loop():
	while player and health > 0:
		$AnimationPlayer.play("shoot")
		await get_tree().create_timer(shoot_interval).timeout
	is_shooting = false
	if health > 0:
		$AnimationPlayer.play("idle")

# Add a Call Method Track to "shoot" animation that calls this at the right frame
func shoot_fireball():
	if not player or not is_instance_valid(player):
		return
	var fireball = fireball_scene.instantiate()
	fireball.global_position = global_position
	fireball.direction = (player.global_position - global_position).normalized()
	get_tree().current_scene.add_child(fireball)

func take_damage(_vel: Vector2):
	print("Enemy hit!")
	health -= 1
	flash()
	if health <= 0:
		die()


func die():
	$AnimationPlayer.play("dead")
	await get_tree().create_timer(1.0).timeout
	queue_free()

func _on_hitbox_area_entered(area: Area2D) -> void:
	print("Something hit me:", area.name)
	if area.is_in_group("Sword") or area.name == "Player/sword":
		print("Ranger got hit!")
		take_damage(Vector2.ZERO)

func flash():
	var mat := $Sprite2D.material as ShaderMaterial
	mat.set_shader_parameter("flash_modifier", 1.0)
	await get_tree().create_timer(0.2).timeout
	mat.set_shader_parameter("flash_modifier", 0.0)
