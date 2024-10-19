extends Node

#These are references we grab on ready for easy access
@onready var settings = get_parent()
@onready var chara_controller = get_parent().get_parent() #We find the character controller


#This handles the control inputs
func _control_process(delta):
	#These are input/action shortcuts
	var move_right = Input.is_action_pressed(settings.move_right_action)
	var move_left = Input.is_action_pressed(settings.move_left_action)
	var not_moving_x = not move_right and not move_left #This checks to see if both move inputs are not being pressed
	
	var move_up = Input.is_action_pressed(settings.move_up_action)
	var move_down = Input.is_action_pressed(settings.move_down_action)
	var not_moving_y = not move_up and not move_down and settings.movement_type == 1 #This checks to see if both move inputs are not being pressed
	
	#If we are moving right
	if move_right:
		if chara_controller.velocity.x < 0: #If the character is currently running Left
			quick_turn("X")
		
		chara_controller.velocity.x += settings.move_speed * delta #This applies acceleration
	
	#If we are moving left
	if move_left:
		if chara_controller.velocity.x > 0: #If the character is currently running Right
			quick_turn("X")
		
		chara_controller.velocity.x -= settings.move_speed * delta #This applies acceleration
	
	#If we are moving left
	if move_up:
		if chara_controller.velocity.y > 0: #If the character is currently running Down
			quick_turn("Y")
		
		chara_controller.velocity.y -= settings.move_speed * delta #This applies acceleration
	
	#If we are moving left
	if move_down:
		if chara_controller.velocity.y < 0: #If the character is currently running Up
			quick_turn("Y")
		
		chara_controller.velocity.y += settings.move_speed * delta #This applies acceleration
	
	#If we're not moving
	if not_moving_x:
		decelerate("X")
	if not_moving_y:
		decelerate("Y")
	
	#We then clamp their movement speed to their speed_max
	chara_controller.velocity.x = clamp(chara_controller.velocity.x, -settings.move_speed_max, settings.move_speed_max)

#This handles decelerating the velocity of the character
func decelerate(_axis):
	#It matches the axis needing to be decelerated then multiplies the velocity by the decel factor
	match _axis: 
		"X":
			chara_controller.velocity.x *= settings.deceleration_factor
		"Y":
			chara_controller.velocity.y *= settings.deceleration_factor
	
	check_to_stop() #This checks to see if the character needs to stop

#This handles to see if the character needs to stop
func check_to_stop():
	if abs(chara_controller.velocity.x) <= 1: #If they're going slow enough we stop them completely
		chara_controller.velocity.x = 0
	
	if settings.movement_type == 1: #If it's a free move controller
		if abs(chara_controller.velocity.y) <= 1: #If they're going slow enough we stop them completely
			chara_controller.velocity.y = 0

#This handles quick turns so running one direction then run another
func quick_turn(_axis):
	#We match the axis we want to quick turn then quick turn it
	match _axis:
		"X":
			chara_controller.velocity.x *= settings.quick_turn_factor #We decelerate them with the quick turn factor
		
		"Y":
			chara_controller.velocity.y *= settings.quick_turn_factor #We decelerate them with the quick turn factor


