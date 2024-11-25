extends enemy_movement
var coin_scene = preload("res://Scenes/Interactables/Coin.tscn")
func _ready():
	random_generation()
	player = get_parent().get_node("Player")

func _on_timer_timeout():
	random_generation()
	player = get_parent().get_node("Player")
	$Timer.start()


func _on_enemy_hitbox_area_entered(area: Area2D):
	if area.is_in_group("Sword"):
		health -= 1
		flash()
		print("Enemy Health: ",health)
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

 #func damage_player():
	 #if player:
		 #var player_health = player.get("player_data").health
	 #if player_data.health > 0:
		 #player.get("player_data").health -= 1  # Decrease player health
		 #print("Player Health: " + str(player.get("player_data").health))
	 #else:
		 #print("Player is dead!")

func damage_player():
	if player and player.has_method("take_damage"):  # Check if the player reference exists and has take_damage
		player.take_damage()  # Call the player's take_damage function
		print("Player damaged!")
	else:
		print("Error: Player is not valid or does not have a take_damage method!")
