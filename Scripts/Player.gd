extends CharacterBody2D

var input_movement = Vector2.ZERO
var speed = 70

func _ready():
	$BasicSword/CollisionShape2D.disabled = true


func _physics_process(delta):
	move()

func move():
	input_movement = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if input_movement != Vector2.ZERO:
		velocity = input_movement * speed
	
	if input_movement == Vector2.ZERO:
		velocity = Vector2.ZERO
		
	move_and_slide()
