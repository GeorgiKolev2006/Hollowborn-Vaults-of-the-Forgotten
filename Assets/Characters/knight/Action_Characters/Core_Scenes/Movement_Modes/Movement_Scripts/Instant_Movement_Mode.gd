extends Node

#These are references we grab on ready for easy access
@onready var chara_controller = get_parent().get_parent() #We get the Action! Character in-use
@onready var settings = get_parent()


#This handles movement input
func _control_process(delta):
	#These are the input shortcuts
	var move_right = Input.is_action_pressed(settings.move_right_action)
	var move_left = Input.is_action_pressed(settings.move_left_action)
	
	var move_up = Input.is_action_pressed(settings.move_up_action) and settings.movement_type == 1
	var move_down = Input.is_action_pressed(settings.move_down_action) and settings.movement_type == 1
	
	chara_controller.velocity.x = 0 #For instant movement we always set velocity x to 0
	
	if settings.movement_type == 1: #If it's a top-down/free move game
		chara_controller.velocity.y = 0 #For instant movement we always set velocity y to 0
	
	
	#If they move right or left we set the velocity X accordingly
	if move_right:
		chara_controller.velocity.x = get_parent().move_speed
	if move_left:
		chara_controller.velocity.x = -get_parent().move_speed
	
	#If they move up or down we set the velocity Y accordingly
	if move_up:
		chara_controller.velocity.y = -get_parent().move_speed
	if move_down:
		chara_controller.velocity.y = get_parent().move_speed


