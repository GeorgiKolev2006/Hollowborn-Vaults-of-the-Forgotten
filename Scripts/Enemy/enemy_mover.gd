extends CharacterBody2D
class_name enemy_movement

var current_states = enemy_states.MOVEDOWN
enum enemy_states {MOVERIGHT, MOVELEFT, MOVEUP, MOVEDOWN, DEAD}

@onready var dead_anim = preload("res://Scenes/Effects/dead_fx.tscn")
@onready var coin_loot = preload("res://Scenes/Interactables/coin.tscn")
@export var speed = 20
@export var health = 3
var dir

func _physics_process(delta):
	if health <= 0:
		current_states = enemy_states.DEAD

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
	move_and_slide()

func random_generation():
	dir = randi() % 4
	random_direction()

func random_direction():
	match dir:
		0:
			current_states = enemy_states.MOVERIGHT
		1:
			current_states = enemy_states.MOVELEFT
		2:
			current_states = enemy_states.MOVEUP
		3:
			current_states = enemy_states.MOVEDOWN

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

func dead():
	dead_animation()
	queue_free()

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
