extends Node

signal Jumped

#Reference Nodes
@onready var settings = get_parent()

var variable_jump_available = false #This will tell if we need to do a variable jump or normal jump


func _ready():
	set_physics_process(false) #We set the physics process to false since all jump modes exist at once; but not all will be used at once.

#This enables the physics process and thus the functionality of this mode
func _enable():
	set_physics_process(true)

#This disables the physics process
func _disable():
	set_physics_process(false)

#This is where various state check stuff happens at
func _physics_process(delta):
	settings.landing_check() #This checks if we've landed
	
	settings.coyote_jump_check() #This checks if we can still coyote jump
	
	_control_process() #This will run controls

#This handles the control inputs
func _control_process():
	#If the character isn't playable we just leave
	if not settings.chara_controller.is_playable: return
	
	#This is a variable shortcut for jump which waits for the input and the function check to return true
	var jump_launch = Input.is_action_just_pressed(settings.jump_action) and settings.can_jump() and not variable_jump_available
	var jump_continue = Input.is_action_pressed(settings.jump_action) and variable_jump_available and settings.can_jump()
	
	#If the character is jumping but not holding down the jump button
	if variable_jump_available and not jump_continue:
		variable_jump_available = false #Then we set VJ to not available now
		settings.lose_jump() #And lose a jump since they've canceled their full jump
	
	if jump_launch: #If they can jump then they will
		_jump_launch()
	
	if jump_continue: #If they can use the variable jump it will
		_jump_continued()

#This handles the jumping logic
func _jump_launch():
	emit_signal("Jumped") #This sends out the Jumped signal
	
	settings.apply_force(settings.jump_power, Vector2.UP) #Move character upward
	variable_jump_available = true #And we allow for the VJ 

#This handles the jumping logic
func _jump_continued():
	#If there's no jump time left for the VJ
	if settings.jump_time_left <= 0:
		variable_jump_available = false #We set the VJ to no longer available
		settings.lose_jump() #We lose a jump
		settings.reset_jump_time() #And we also reset the jump time
		return #We leave so we don't give them an extra jump
	
	#OTHERWISE if we still have jump time left
	
	settings.jump_time_left -= 1 #We reduce jump time
	settings.apply_force(settings.jump_power_variable, Vector2.UP) #Move character upward


