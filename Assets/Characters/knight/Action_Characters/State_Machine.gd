extends Node

#This is the default state machine
#You'll want to duplicate and create your own version but this is a start

var state = "Idle" #This is the current state the character is in
@onready var chara_body = get_parent() #This is the Action! Character in-use
@onready var action_sprite = get_parent().get_node("Action_Sprite") #This is the Action! Sprite in-use


#This makes necessary connections when the game begins
func _setup():
	var jump_node = chara_body.jump_node
	
	jump_node.connect("Jumped", _change_state.bind("Jump"))
	jump_node.connect("Landed", _change_state.bind("Idle"))

#This checks states and ensures the character is in the correct state.
func _check_states():
	if not chara_body.is_alive: #If the character isn't alive
		_change_state("Dead") #Change their state to dead
	
	if state == "Idle": #If the state is Idle
		if chara_body.is_on_floor(): #If the character is on the floor
			if chara_body.velocity.x != 0: #If the character is moving
				_change_state("Run") #Then the state should be Run
	
	if state == "Run": #If the state is Run
		if chara_body.is_on_floor(): #If the character is on the floor
			if chara_body.velocity.x == 0: #If the character isn't moving
				_change_state("Idle") #Then the state should be Idle
	
	if state == "Jump":
		if chara_body.velocity.y > 0:
			_change_state("Fall")

#This handles changing the state and what happens in a state change
func _change_state(_new_state):
	match _new_state:
		"Idle":
			#We set the animation to Idle on the Base animation machine
			action_sprite._update_animation("Idle", "Base")
		"Run":
			#We set the animation to Run on the Base animation machine
			action_sprite._update_animation("Run", "Base")
		"Jump":
			#We set the animation to Jump on the Base animation machine
			action_sprite._update_animation("Jump", "Base")
		"Fall":
			#We set the animation to Fall on the Base animation machine
			action_sprite._update_animation("Fall", "Base")
		
		"Hurt":
			pass
		"Dead":
			set_physics_process(false) #We turn off the physics process
			await get_tree().create_timer(2).timeout #We wait a couple seconds
			get_tree().reload_current_scene() #Then reload the scene
	
	state = _new_state #The state should become the new state
