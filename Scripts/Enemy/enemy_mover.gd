extends CharacterBody2D
class_name enemy_movement

var current_states = enemy_states.MOVEDOWN
enum enemy_states {MOVERIGHT, MOVELEFT, MOVEUP, MOVEDOWN, DEAD, CHASE, AVOIDING}

@onready var dead_anim = preload("res://Scenes/Effects/dead_fx.tscn")
@onready var coin_loot = preload("res://Scenes/Interactables/coin.tscn")
@onready var hitbox_area = $EnemyHitbox
@onready var attack_area = $EnemyAttack
@onready var stuck_timer = $StuckTimer
@export var detection_radius = 200.0
@export var speed = 30
@export var health = 3

var can_take_damage = true
var damage_cooldown = 0.2
var dir = Vector2.ZERO
var stuck_duration = 0.5
var last_position = Vector2.ZERO
var player = null
var navigation = null

func _ready() -> void:
	player = get_tree().get_root().find_child("Player", true, false)
	navigation = get_tree().get_root().find_child("Navigation2D", true, false)

	random_generation()
	stuck_timer.wait_time = stuck_duration
	stuck_timer.one_shot = true
	if not stuck_timer.is_connected("timeout", Callable(self, "_on_stuck_timeout")):
		stuck_timer.connect("timeout", Callable(self, "_on_stuck_timeout"))

func _physics_process(delta):
	if health <= 0:
		current_states = enemy_states.DEAD

	if player and hitbox_area.overlaps_body(player):
		velocity = Vector2.ZERO
	else:
		if player and (global_position.distance_to(player.global_position) <= detection_radius):
			current_states = enemy_states.CHASE
		elif current_states == enemy_states.CHASE:
			random_generation()

	match current_states:
		enemy_states.MOVERIGHT:
			move_right()
		enemy_states.MOVELEFT:
			move_left()
		enemy_states.MOVEUP:
			move_up()
		enemy_states.MOVEDOWN:
			move_down()
		enemy_states.DEAD:
			dead()
		enemy_states.CHASE:
			chase_player()
		enemy_states.AVOIDING:
			avoid_obstacles()

	if global_position.distance_to(last_position) < 5:
		if stuck_timer.is_stopped():
			stuck_timer.start()
	else:
		stuck_timer.stop()

	last_position = global_position
	move_and_slide()

func random_generation():
	dir = randi() % 4
	random_direction()

func random_direction():
	match dir:
		0: current_states = enemy_states.MOVERIGHT
		1: current_states = enemy_states.MOVELEFT
		2: current_states = enemy_states.MOVEUP
		3: current_states = enemy_states.MOVEDOWN

func move_right():
	velocity = Vector2.RIGHT * speed
	$anim.play("move_right")

func move_left():
	velocity = Vector2.LEFT * speed
	$anim.play("move_left")

func move_up():
	velocity = Vector2.UP * speed
	$anim.play("move_up")

func move_down():
	velocity = Vector2.DOWN * speed
	$anim.play("move_down")

func chase_player():
	if player:
		dir = (player.global_position - global_position).normalized()
		velocity = dir * speed
		if abs(dir.x) > abs(dir.y):
			if dir.x > 0:
				$anim.play("move_right")
			else:
				$anim.play("move_left")
		else:
			if dir.y > 0:
				$anim.play("move_down")
			else:
				$anim.play("move_up")

func avoid_obstacles():
	dir = Vector2.UP if randi() % 2 == 0 else Vector2.DOWN
	velocity = dir * speed

func _on_stuck_timeout():
	current_states = enemy_states.AVOIDING

func dead():
	dead_animation()
	queue_free()
	PlayerData.score += 50
	PlayerData.save_to_firebase()

func dead_animation():
	var dead = dead_anim.instantiate()
	dead.global_position = global_position
	get_tree().get_root().add_child(dead)
	loot_coin()

func loot_coin():
	if randf() < 0.5:
		var coin = coin_loot.instantiate()
		coin.global_position = global_position
		get_tree().get_root().add_child(coin)

func apply_knockback(force: Vector2):
	velocity += force * 3
	move_and_slide()
	await get_tree().create_timer(0.3).timeout
	velocity = Vector2.ZERO
