extends enemy_movement

var coin_scene = preload("res://Scenes/Interactables/Coin.tscn")

func _ready():
	random_generation()
	player = get_tree().get_root().find_child("Player", true, false)
	if not $Timer.is_connected("timeout", Callable(self, "_on_timer_timeout")):
		$Timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	if not $EnemyHitbox.is_connected("area_entered", Callable(self, "_on_enemy_hitbox_area_entered")):
		$EnemyHitbox.area_entered.connect(Callable(self, "_on_enemy_hitbox_area_entered"))
	if not $EnemyAttack.is_connected("area_entered", Callable(self, "_on_enemy_attack_area_entered")):
		$EnemyAttack.area_entered.connect(Callable(self, "_on_enemy_attack_area_entered"))

func _on_timer_timeout():
	random_generation()
	player = get_tree().get_root().find_child("Player", true, false)
	$Timer.start()

func _on_enemy_hitbox_area_entered(area: Area2D):
	if area.is_in_group("Sword") and can_take_damage:
		health -= 1
		flash()
		print("Enemy Health: ", health)
		var knockback_direction = (global_position - area.global_position).normalized()
		apply_knockback(knockback_direction * 150)
		can_take_damage = false
		await get_tree().create_timer(damage_cooldown).timeout
		can_take_damage = true
		if health <= 0:
			dead()

func _on_enemy_attack_area_entered(area: Area2D):
	if area.is_in_group("Player"):
		print("Player detected!")
		damage_player()

func flash():
	$Sprite2D.material.set_shader_parameter("flash_modifier", 0.7)
	await get_tree().create_timer(0.3).timeout
	$Sprite2D.material.set_shader_parameter("flash_modifier", 0)

func damage_player():
	if player and player.has_method("take_damage"):
		player.take_damage(Vector2.ZERO)
		print("Player damaged!")
	else:
		print("Error: Player is not valid or has no 'take_damage' method!")
