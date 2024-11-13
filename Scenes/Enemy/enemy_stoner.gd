extends enemy_movement
var coin_scene = preload("res://Scenes/Interactables/Coin.tscn")
var player = null

func _ready():
	random_generation()
	player = get_parent().get_node("Player")


func _on_timer_timeout():
	random_generation()
	$Timer.start()


func _on_enemy_hitbox_area_entered(area: Area2D):
	if area.is_in_group("Sword"):
		health -= 1
		flash()
		print(health)
	elif area.is_in_group("Player"):
		damage_player()

func flash():
	$Sprite2D.material.set_shader_parameter("flash_modifier", 0.7)
	await get_tree().create_timer(0.3).timeout
	$Sprite2D.material.set_shader_parameter("flash_modifier", 0)

func damage_player():
	if player:
		# Assuming player_data is accessible in the player node or via a singleton
		# Make sure you're accessing the player's health correctly
		var player_health = player.get("player_data").health  # Make sure the player has a health property in player_data.gd
	if player_data.health > 0:
		player.get("player_data").health -= 1  # Decrease player health
		print("Player Health: " + str(player.get("player_data").health))
	else:
		print("Player is dead!")
