extends CharacterBody2D

@onready var anim_tree = $anim_tree
@onready var anim_state = anim_tree.get("parameters/playback")
@onready var coin_scene = preload("res://Scenes/Interactables/coin.tscn")
@onready var enemyVelocity = preload("res://Scripts/Enemy/enemy_mover.gd")
var hitbox_node
var can_damage = true
@export var knockbackPower: int = 500
enum player_states {MOVE, SWORD, JUMP, DEAD}
var current_states = player_states.MOVE
var input_movement = Vector2.ZERO
var save_slot = "players/player1"  # Default save slot

# Declare variable for the Firebase script instance
var firebase_script

func _ready():
	# Instantiate Firebase script instance
	firebase_script = preload("res://Scripts/firebase_test.gd").new()
	
	# Connect the callback functions for Firebase signals
	firebase_script.connect("game_data_loaded", self, "_on_game_data_loaded")
	firebase_script.connect("game_data_saved", self, "_on_game_data_saved")
	
	# Load game data
	firebase_script.load_game(save_slot)
	
	$sword/CollisionShape2D.disabled = true
	$sword.add_to_group("Sword")
	hitbox_node = get_node_or_null("hitbox/hitboxCharacter")

	# Apply loaded position if available
	if Player_data.SavePos != Vector2.ZERO:
		print("🔄 Applying loaded position:", Player_data.SavePos)
		position = Player_data.SavePos  

func _process(delta):
	# Save game (F5)
	if Input.is_action_just_pressed("save_game"):
		print("💾 F5 Pressed: Saving game...")
		firebase_script.save_game(save_slot)

	# Load game (F6)
	if Input.is_action_just_pressed("load_game"):
		print("🔄 F6 Pressed: Loading game...")
		firebase_script.load_game(save_slot)
		await get_tree().create_timer(0.5).timeout  # Allow for loading
		print("📌 Applying position after load:", Player_data.SavePos)
		position = Player_data.SavePos  

	# Delete save (F7)
	if Input.is_action_just_pressed("delete_game"):
		print("🗑️ F7 Pressed: Deleting game...")
		firebase_script.delete_game(save_slot)

func _physics_process(delta):
	match current_states:
		player_states.MOVE: move()
		player_states.SWORD: sword()
		player_states.JUMP: jump()
		player_states.DEAD: dead()

func move():
	input_movement = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if input_movement != Vector2.ZERO:
		anim_tree.set("parameters/Idle/blend_position", input_movement)
		anim_tree.set("parameters/Walk/blend_position", input_movement)
		anim_tree.set("parameters/Sword/blend_position", input_movement)
		anim_tree.set("parameters/Jump/blend_position", input_movement)
		anim_state.travel("Walk")
		velocity = input_movement * Player_data.Playerspeed
	else:
		anim_state.travel("Idle")
		velocity = Vector2.ZERO

	if Input.is_action_just_pressed("sword"):
		current_states = player_states.SWORD

	if Input.is_action_just_pressed("jump"):
		current_states = player_states.JUMP

	if Player_data.health <= 0:
		current_states = player_states.DEAD

	move_and_slide()

func sword():
	anim_state.travel("Sword")

func on_states_reset():
	current_states = player_states.MOVE

func jump():
	anim_state.travel("Jump")
	var dodge_speed = Player_data.Playerspeed * 1.5
	velocity = input_movement * dodge_speed
	clear_collision()
	move_and_slide()
	await get_tree().create_timer(0.5).timeout 
	velocity = input_movement * Player_data.Playerspeed  
	create_collision()
	on_states_reset()

func dead():
	anim_state.travel("Dead")
	await get_tree().create_timer(1).timeout
	Player_data.health = 4
	get_tree().reload_current_scene()
	firebase_script.save_game(save_slot)  # ✅ Save game when dead
	get_tree().reload_current_scene()

func flash():
	$Sprite2D.material.set_shader_parameter("flash_modifier", 0.7)
	await get_tree().create_timer(0.3).timeout
	$Sprite2D.material.set_shader_parameter("flash_modifier", 0)

func clear_collision():
	var hitbox_node = get_node_or_null("hitbox/hitboxCharacter")
	if hitbox_node:
		hitbox_node.disabled = true
	else:
		print("ERROR: hitboxCharacter not found!")

func create_collision():
	$hitbox/hitboxCharacter.disabled = false

func _on_hitbox_area_entered(area):
	var enemy = area.get_parent()
	if enemy is enemy_movement:
		take_damage(enemy.velocity)
	else:
		take_damage(Vector2.ZERO)

func take_damage(enemyVelocity: Vector2):
	if Player_data.health > 0:
		Player_data.health -= 1
		print("Player Health: ", Player_data.health)
		flash()
		knockback(enemyVelocity)
		if Player_data.health <= 0:
			current_states = player_states.DEAD
	else:
		print("Player is already dead!")

func knockback(enemyVelocity: Vector2):
	var knockbackDirection = (enemyVelocity - velocity).normalized() * knockbackPower
	velocity = knockbackDirection
	move_and_slide()
	await get_tree().create_timer(0.2).timeout 
	velocity = Vector2.ZERO

func _on_sword_hit(enemy):
	if enemy is enemy_movement:
		enemy.take_damage(velocity)

# Callback function when game data is loaded
func _on_game_data_loaded():
	print("Game data loaded successfully!")
	position = Player_data.SavePos

# Callback function when game data is saved
func _on_game_data_saved():
	print("Game data saved successfully!")
