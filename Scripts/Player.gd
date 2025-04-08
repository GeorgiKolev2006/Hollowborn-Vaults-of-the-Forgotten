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
var save_slot = "players/player1"

func _ready():
	$sword/CollisionShape2D.disabled = true
	$sword.add_to_group("Sword")
	hitbox_node = get_node_or_null("hitbox/hitboxCharacter")
	FireBase.request_data(save_slot, Callable(self, "_on_game_data_loaded"))

func _process(delta):
	if Input.is_action_just_pressed("save_game"):
		var save_data = {
			"health": Player_data.health,
			"coins": Player_data.coin,
			"score": Player_data.score,
			"SavePos": "%f,%f" % [position.x, position.y]
		}
		FireBase.put_data(save_slot, save_data)
	
	if Input.is_action_just_pressed("load_game"):
		FireBase.request_data(save_slot, Callable(self, "_on_game_data_loaded"))
	
	if Input.is_action_just_pressed("delete_game"):
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

func sword():
	anim_state.travel("Sword")
	await get_tree().create_timer(0.5).timeout
	velocity = Vector2.ZERO
	current_states = player_states.MOVE

func jump():
	anim_state.travel("Jump")
	velocity = Vector2.ZERO  
	var dodge_speed = Player_data.Playerspeed * 1.5
	velocity = input_movement.normalized() * dodge_speed  
	await get_tree().create_timer(0.5).timeout
	current_states = player_states.MOVE
	create_collision()

func dead():
	anim_state.travel("Dead")
	await get_tree().create_timer(1.0).timeout
	Player_data.health = 4
	get_tree().reload_current_scene()

func _on_game_data_loaded(body):
	var data = JSON.parse_string(body.get_string_from_utf8())
	if data:
		Player_data.health = data.get("health", 4)
		Player_data.coin = data.get("coins", 0)
		Player_data.score = data.get("score", 0)
		if "SavePos" in data:
			var pos = data["SavePos"].split(",")
			position = Vector2(float(pos[0]), float(pos[1]))

func flash():
	$Sprite2D.material.set_shader_parameter("flash_modifier", 0.7)
	await get_tree().create_timer(0.3).timeout
	$Sprite2D.material.set_shader_parameter("flash_modifier", 0)

func clear_collision():
	var hitbox_node = get_node_or_null("hitbox/hitboxCharacter")
	if hitbox_node:
		hitbox_node.disabled = true

func create_collision():
	$hitbox/hitboxCharacter.disabled = false

func _on_hitbox_area_entered(area):
	var enemy = area.get_parent()
	if enemy.is_in_group("Enemy"):
		take_damage(enemy.velocity)

func take_damage(enemyVelocity: Vector2):
	if Player_data.health > 0:
		Player_data.health -= 0.5
		flash()
		knockback(enemyVelocity)
		if Player_data.health <= 0:
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
	Player_data.health = min(Player_data.health + amount, Player_data.max_health)
