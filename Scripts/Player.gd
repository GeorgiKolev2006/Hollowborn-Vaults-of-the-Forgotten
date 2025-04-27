extends CharacterBody2D

@onready var anim_tree = $anim_tree
@onready var anim_state = anim_tree.get("parameters/playback")
@onready var coin_scene = preload("res://Scenes/Interactables/coin.tscn")

var hitbox_node
var can_damage = true
@export var knockbackPower: int = 500
var firebase_enabled := true
enum player_states {MOVE, SWORD, JUMP, DEAD}
var current_states = player_states.MOVE
var input_movement = Vector2.ZERO
var save_slot = "players/player1"

func _ready():
	$sword/CollisionShape2D.disabled = true
	$sword.add_to_group("Sword")
	hitbox_node = get_node_or_null("hitbox/hitboxCharacter")

	var current_scene = get_tree().current_scene.scene_file_path
	print("🔍 Current scene:", current_scene)

	if current_scene == "res://Scenes/Levels/tutorial.tscn":
		firebase_enabled = false
		print("📛 Firebase DISABLED for tutorial!")
		position = Vector2(300, 200)  # 🛠 Set nice tutorial spawn manually
	else:
		firebase_enabled = true
		FireBase.request_data(save_slot, Callable(self, "_on_game_data_loaded"))


func _process(delta):
	if Input.is_action_just_pressed("save_game"):
		save_game()
	if Input.is_action_just_pressed("load_game"):
		load_game()
	if Input.is_action_just_pressed("delete_game"):
		if firebase_enabled:
			FireBase.delete_data(save_slot)

func _physics_process(delta):
	match current_states:
		player_states.MOVE:
			move()
			move_and_slide()
		player_states.SWORD:
			sword()
		player_states.JUMP:
			jump()
			move_and_slide()
		player_states.DEAD:
			dead()

func move():
	input_movement = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if input_movement != Vector2.ZERO:
		anim_tree.set("parameters/Idle/blend_position", input_movement)
		anim_tree.set("parameters/Walk/blend_position", input_movement)
		anim_tree.set("parameters/Sword/blend_position", input_movement)
		anim_tree.set("parameters/Jump/blend_position", input_movement)
		anim_state.travel("Walk")
		velocity = input_movement * PlayerData.Playerspeed
	else:
		anim_state.travel("Idle")
		velocity = Vector2.ZERO

	if Input.is_action_just_pressed("sword"):
		current_states = player_states.SWORD
	if Input.is_action_just_pressed("jump"):
		current_states = player_states.JUMP
	if PlayerData.health <= 0:
		current_states = player_states.DEAD

func sword():
	anim_state.travel("Sword")
	$sword/CollisionShape2D.disabled = false
	await get_tree().create_timer(0.2).timeout
	$sword/CollisionShape2D.disabled = true
	await get_tree().create_timer(0.3).timeout
	velocity = Vector2.ZERO
	current_states = player_states.MOVE

func jump():
	anim_state.travel("Jump")
	velocity = Vector2.ZERO  
	var dodge_speed = PlayerData.Playerspeed * 1.5
	velocity = input_movement.normalized() * dodge_speed  
	await get_tree().create_timer(0.5).timeout
	current_states = player_states.MOVE
	create_collision()

func dead():
	anim_state.travel("Dead")
	await get_tree().create_timer(1.0).timeout
	PlayerData.health = 4
	get_tree().reload_current_scene()

func _on_game_data_loaded(body: PackedByteArray):
	if not firebase_enabled:
		print("📛 Skipping _on_game_data_loaded because Firebase is disabled.")
		return

	var data = JSON.parse_string(body.get_string_from_utf8())
	if data:
		PlayerData.health = data.get("health", 4)
		PlayerData.coin = data.get("coins", 0)
		PlayerData.score = data.get("score", 0)
		PlayerData.current_level = data.get("current_level", 1)
		PlayerData.damage = data.get("damage", 1.0)
		PlayerData.Playerspeed = data.get("Playerspeed", 100)

		var save_pos_str = data.get("SavePos", "100,200")
		var pos_split = save_pos_str.split(",")
		if pos_split.size() == 2:
			position = Vector2(pos_split[0].to_float(), pos_split[1].to_float())
		else:
			print("⚠️ SavePos invalid, using default.")
			position = Vector2(100, 200)

		PlayerData.SavePos = position
		
		# 🔥 Here is the important new fix:
		var current_scene_path = get_tree().current_scene.scene_file_path
		if current_scene_path != "res://Scenes/Levels/tutorial.tscn":
			var next_scene = ""
			match PlayerData.current_level:
				1:
					next_scene = "res://Scenes/Levels/main_level.tscn"
				2:
					next_scene = "res://Scenes/Levels/second_level.tscn"
				_:
					next_scene = "res://Scenes/Levels/main_level.tscn"

			if current_scene_path != next_scene:
				get_tree().change_scene_to_file(next_scene)
	else:
		print("⚠️ No save data found!")


func save_game():
	if not firebase_enabled:
		print("📛 Skipping save because Firebase is disabled.")
		return

	var save_data = {
		"health": PlayerData.health,
		"coins": PlayerData.coin,
		"score": PlayerData.score,
		"SavePos": "%f,%f" % [position.x, position.y],
		"current_level": PlayerData.current_level,
		"damage": PlayerData.damage,
		"Playerspeed": PlayerData.Playerspeed
	}
	FireBase.put_data(save_slot, save_data)
	print("✅ Game saved successfully.")

func load_game():
	if not firebase_enabled:
		print("📛 Skipping load because Firebase is disabled.")
		return

	FireBase.request_data(save_slot, Callable(self, "_on_game_data_loaded"))
	print("✅ Game load requested.")

func flash():
	$Sprite2D.material.set_shader_parameter("flash_modifier", 0.7)
	await get_tree().create_timer(0.3).timeout
	$Sprite2D.material.set_shader_parameter("flash_modifier", 0)

func clear_collision():
	var hitbox_node = get_node_or_null("hitbox/hitboxCharacter")
	if hitbox_node:
		hitbox_node.disabled = true

func create_collision():
	var hitbox_node = get_node_or_null("hitbox/hitboxCharacter")
	if hitbox_node:
		hitbox_node.disabled = false


func _on_hitbox_area_entered(area):
	var enemy = area.get_parent()
	if enemy.is_in_group("Enemy"):
		take_damage(enemy.velocity)

func take_damage(enemyVelocity: Vector2):
	if PlayerData.health > 0:
		PlayerData.health -= 0.5
		flash()
		knockback(enemyVelocity)
		if PlayerData.health <= 0:
			current_states = player_states.DEAD

func knockback(enemyVelocity: Vector2):
	var knockbackDirection = (enemyVelocity - velocity).normalized() * knockbackPower
	velocity = knockbackDirection
	move_and_slide()
	await get_tree().create_timer(0.2).timeout
	velocity = Vector2.ZERO

func _on_sword_hit(enemy):
	if enemy is enemy_movement:
		enemy.take_damage(velocity)

func increase_health(amount: float):
	PlayerData.health = min(PlayerData.health + amount, PlayerData.max_health)
