extends Node

signal Jumped

@onready var settings = get_parent()


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
	var jump = Input.is_action_just_pressed(get_parent().jump_action) and settings.can_jump()
	
	if jump: #If they can jump then they will
		_jump()

#This handles the jumping logic
func _jump():
	emit_signal("Jumped") #This sends out the Jumped signal
	
	settings.apply_force(settings.jump_power, Vector2.UP) #We apply the jump power
	
	settings.lose_jump() #Reduce jump count

