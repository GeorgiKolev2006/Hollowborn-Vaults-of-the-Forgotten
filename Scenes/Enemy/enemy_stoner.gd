extends enemy_movement

func _ready():
	random_generation()
	print(dir)


func _on_timer_timeout():
	random_generation()
	$Timer.start()


func _on_enemy_hitbox_area_entered(area: Area2D):
	if area.is_in_group("Sword"):
		health -= 1
		flash()
		print(health)

func flash():
	$Sprite2D.material.set_shader_parameter("flash_modifier", 0.7)
	await get_tree().create_timer(0.3).timeout
	$Sprite2D.material.set_shader_parameter("flash_modifier", 0)
