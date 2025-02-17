extends CharacterBody2D

@onready var anim_tree = $anim_tree
@onready var anim_state = anim_tree.get("parameters/playback")
@onready var coin_scene = preload("res://Scenes/Interactables/coin.tscn")
@onready var enemyVelocity = preload("res://Scripts/Enemy/enemy_mover.gd")

@export var knockbackPower: int = 500
enum player_states {MOVE, SWORD, JUMP, DEAD}
var current_states = player_states.MOVE
var input_movement = Vector2.ZERO
var playerData = Player_data.new()

func _ready():
	$sword.add_to_group("Sword")
	$sword/CollisionShape2D.disabled = true
	FireBase.load_game()
	if PlayerData.SavePos != Vector2.ZERO:
		print("🔄 Applying loaded position:", PlayerData.SavePos)
		call_deferred("set_position", PlayerData.SavePos)  # Ensures position updates correctly

func _process(delta):
	if Input.is_action_just_pressed("save_game"):
		print("F5 pressed: Saving game...")
		FireBase.save_game()
	if Input.is_action_just_pressed("load_game"):
		print("🔄 F6 Pressed! Loading game...")
		FireBase.load_game()
		await get_tree().create_timer(0.5).timeout 
		print("📌 Applying position after load:", PlayerData.SavePos)
		position = PlayerData.SavePos  
	if Input.is_action_just_pressed("delete_game"):  # F7
		print("F7 pressed: Deleting game...")
		FireBase.delete_game()

func _physics_process(delta):
	match current_states:
		player_states.MOVE:	
			move()
		player_states.SWORD:
			sword()
		player_states.JUMP:
			jump()
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
		velocity = input_movement * playerData.Playerspeed

	else:
		anim_state.travel("Idle")
		velocity = Vector2.ZERO
	
	if Input.is_action_just_pressed("sword"):
		current_states = player_states.SWORD
	
	if Input.is_action_just_pressed("jump"):
		current_states = player_states.JUMP
	
	if player_data.health <= 0:
		current_states = player_states.DEAD
	
	move_and_slide()

func sword():
	anim_state.travel("Sword")

func on_states_reset():
	current_states = player_states.MOVE

func jump():
	anim_state.travel("Jump")
	velocity = input_movement * playerData.Playerspeed
	move_and_slide()

func dead():
	anim_state.travel("Dead")
	await get_tree().create_timer(1).timeout
	player_data.health = 4
	get_tree().reload_current_scene()
	Firebase.save_game()
	get_tree().reload_current_scene()

func flash():
	$Sprite2D.material.set_shader_parameter("flash_modifier", 0.7)
	await get_tree().create_timer(0.3).timeout
	$Sprite2D.material.set_shader_parameter("flash_modifier", 0)

func clear_collision():
	$CollisionShape2D.disabled = true

func create_collision():
	$CollisionShape2D.disabled = false

func _on_hitbox_area_entered(area):
	var enemy = area.get_parent()
	if enemy is enemy_movement:
		take_damage(enemy.velocity)
	else:
		take_damage(Vector2.ZERO)

func take_damage(enemyVelocity: Vector2):
	if player_data.health > 0:
		player_data.health -= 1
		print("Player Health: ", player_data.health)
		flash()
		knockback(enemyVelocity)
		if player_data.health <= 0:
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
