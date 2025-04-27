extends CharacterBody2D

signal died

@onready var sprite = $Sprite2D
@onready var progress_bar = $UI/ProgressBar
@onready var fsm = find_child("FiniteStateMachine")
@onready var hitbox = $Hitbox  # Area2D that detects sword hits
var should_follow: bool = false
var DEF := 0
var health: int = 100
var player: Node2D = null
var direction: Vector2 = Vector2.ZERO

func _ready():
	progress_bar.value = health

	player = get_tree().get_root().find_child("Player", true, false)
	if player == null:
		print("⚠️ Player not found!")

	# ✅ Listen for sword hits
	if hitbox:
		hitbox.connect("area_entered", Callable(self, "_on_hitbox_area_entered"))

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Sword") or area.name == "Player/sword":
		var dmg := PlayerData.damage * 5
		take_damage(dmg)

func take_damage(amount: int):
	var actual_damage = max(0, amount - DEF)
	health -= actual_damage
	progress_bar.value = health
	print("💥 Golem took", actual_damage, "damage. Health:", health)
	flash()
	if health <= 0:
		die()

func flash():
	var shader_mat := sprite.material as ShaderMaterial
	shader_mat.set_shader_parameter("Flash Modifier", 1.0)
	await get_tree().create_timer(0.1).timeout
	shader_mat.set_shader_parameter("Flash Modifier", 0.0)

func die():
	print("💀 Golem died")
	emit_signal("died")
	if fsm:
		fsm.change_state("died")
	progress_bar.visible = false
	queue_free()

func _process(_delta):
	if player:
		direction = player.global_position - global_position
		sprite.flip_h = direction.x < 0

func _physics_process(delta):
	if should_follow and player:
		velocity = direction.normalized() * 40
		move_and_slide()
	else:
		velocity = Vector2.ZERO
