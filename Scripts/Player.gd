extends CharacterBody2D

@onready var anim_tree = $anim_tree
@onready var anim_state = anim_tree.get("parameters/playback")
@onready var coin_scene = preload("res://Scenes/Interactables/coin.tscn")

var save_file_path = "user://save/"
var save_file_name = "PlayerSave.tres"

enum player_states {MOVE, SWORD, JUMP, DEAD}
var current_states = player_states.MOVE

var input_movement = Vector2.ZERO
var playerData = Player_data.new()

func _ready():
	$sword/CollisionShape2D.disabled = true
	load_data()

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
	
	if input_movement == Vector2.ZERO:
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

func flash():
	$Sprite2D.material.set_shader_parameter("flash_modifier", 0.7)
	await get_tree().create_timer(0.3).timeout
	$Sprite2D.material.set_shader_parameter("flash_modifier", 0)
	
func clear_collision():
	$CollisionShape2D.disabled = true

func create_collision():
	$CollisionShape2D.disabled = false

func _on_hitbox_area_entered(area):
	flash()

func save_data():
	var playerData = Player_data.new()
	playerData.SavePos = position
	playerData.health = playerData.health
	playerData.coin = playerData.coin
	var save_file = ResourceSaver.save(save_file_path + save_file_name, playerData)
	if save_file == OK:
		print("Game saved successfully")
	else:
		print("Failed to save game")

func load_data():
	var loaded_data = ResourceLoader.load(save_file_path + save_file_name)
	if loaded_data and loaded_data is Player_data:
		playerData = loaded_data
		print("Game loaded successfully")
		apply_loaded_data()  # Make sure this line is properly indented
	else:
		print("No saved game found or failed to load")

func apply_loaded_data():
	position = playerData.SavePos
	playerData.health = playerData.health
	playerData.coin = playerData.coin
