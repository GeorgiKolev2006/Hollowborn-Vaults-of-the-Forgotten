extends CharacterBody2D
class_name enemy_movement

var current_states = enemy_states.MOVEDOWN
enum enemy_states {MOVERIGHT, MOVELEFT, MOVEUP, MOVEDOWN}

@export var speed = 20
var dir

func _physics_process(delta):
	match current_states:
		enemy_states.MOVERIGHT:
			move_right()
			
	match current_states:
		enemy_states.MOVELEFT:
			move_left()
			
	match current_states:
		enemy_states.MOVEUP:
			move_up()
			
	match current_states:
		enemy_states.MOVEDOWN:
			move_down()
			
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
	velocity = Vector2.DOWN * speed
	$anim.play("move_down")

func move_down():
	velocity = Vector2.UP * speed
	$anim.play("move_up")
