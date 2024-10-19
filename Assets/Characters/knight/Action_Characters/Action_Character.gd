@tool
extends CharacterBody2D

#Signals!
signal Out_Of_Bounds

#Please report any bugs to rebelpawsstudio@gmail.com!

#These are some needed scenes for the plugin to work right. Most are preset.
@export_group("Essentials") 
var action_sprite_scene = preload("res://addons/Action_Characters/Core_Scenes/Action_Sprite/Action_Sprite.tscn")
@export var move_settings_scene = preload("res://addons/Action_Characters/Core_Scenes/Movement_Modes/Movement_Settings.tscn")
@export var jump_settings_scene = preload("res://addons/Action_Characters/Core_Scenes/Movement_Modes/Jump_Settings.tscn")

@export var preserve_collider = false ##This will stop the collider from being deleted if removing the AS essentials. (Will auto-deactivate if a collider hasn't been generated)

@export var action_sprite_essentials : PackedScene: ##This is the essential scene that holds a sprites layers and animation machines
	set(val): #When the value is changed this is called
		action_sprite_essentials = val #We make sure we assign the new value
		
		if preserve_collider == true and get_node("Collider") == null:
			preserve_collider = false
		
		if action_sprite_essentials != null:
			_setup_sprite() #Then we call setup to get our new action sprite
		else:
			get_node("Action_Sprite").queue_free()
			
			if not preserve_collider:
				get_node("Collider").queue_free()

@export var state_machine : PackedScene: ##This will be your state machine node that will hold all your state information.
	set(val): #When the value is changed this is called
		state_machine = val #We make sure we assign the new value
		
		if state_machine != null:
			_setup_behavior() #Then we call setup to get our new state machine
		else:
			get_node("State_Machine").queue_free()
			get_node("Movement_Modes").queue_free()
			get_node("Jump_Modes").queue_free()


#These settings are some basic setup options
@export_group("Basic Settings")
var is_alive = true #Tells the code whether the character is alive or not
@export_enum("Right", "Left") var starting_direction = 0: ##This will set the visual for the starting direction of the character (purely aesthetic)
	set(val): #When the value is changed this is called
		starting_direction = val #We make sure we assign the new value
		if val == 0: #If it's 0 aka Right then we'll play the right animation on the direction animation machine
			get_node("Action_Sprite")._update_animation("Right", "Direction")
		if val == 1: #If it's 1 aka Left then we'll play the left animation on the direction animation machine
			get_node("Action_Sprite")._update_animation("Left", "Direction")
@export var directions_to_update = {"X": true, "Y": false}
@export var is_playable = false ##This tells the code whether or not the character is playable. If the character is not playable input control code won't run.

@export var enable_boundaries = {"X-Bounds": false, "Y-Bounds": true} ##This lets you enable boundaries for each axis
@export var out_of_bounds = { ##This is the bounds for the game the first number for each axis is the lowest value they can go to and the second number is the highest they value they can go to
							"X-Bounds": [0, 0],
							"Y-Bounds": [0, 0]
							} 

#These hold the nodes for each movement system for easy access
var jump_node
var movement_node


func _ready():
	if Engine.is_editor_hint(): #If the user is in the editor
		set_physics_process(false) #Turn of physics process just to keep it simple
	
	if not Engine.is_editor_hint(): #If the user is in-game
		set_physics_process(true) #We need physics process to run
		
		jump_node = get_node("Jump_Settings").get_child($Jump_Settings.jump_mode)
		movement_node = get_node("Movement_Settings").get_child($Movement_Settings.movement_mode)
		
		jump_node._enable() #Enable the jump mode we're using.
	
	$State_Machine._setup()

#This sets up the characters sprite systems!
func _setup_sprite():
	if not Engine.is_editor_hint(): return #If the user isn't in the editor then this shouldn't run.
	
	#Generates Action! Sprite
	var action_sprite = action_sprite_scene.instantiate()
	add_child(action_sprite)
	action_sprite.set_owner(get_tree().get_edited_scene_root())
	action_sprite.name = "Action_Sprite"
	
	#Generates CollisionShape2D
	if not preserve_collider and get_node("Collider") == null:
		var collider = CollisionShape2D.new() #Creates the collision shape
		add_child(collider) #Add the collider to the scene tree
		collider.set_owner(get_tree().get_edited_scene_root()) #Then sets the parent of the collider
		collider.name = "Collider" #Rename it for consistency
		
		var collision_shape= RectangleShape2D.new()
		collision_shape.size = Vector2(1, 1)
		
		collider.shape = collision_shape

#This sets up the characters gameplay systems!
func _setup_behavior():
	if not Engine.is_editor_hint(): return #If the user isn't in the editor then this shouldn't run.
	
	#Generates the state machine
	var new_state_machine = state_machine.instantiate()
	add_child(new_state_machine) #Add the node as a child
	new_state_machine.set_owner(get_tree().get_edited_scene_root()) #We set the parent of the node
	new_state_machine.name = "State_Machine" #Then rename it for consistency.
	
	#Generates Movement Settings tscn
	var move_settings_node = move_settings_scene.instantiate() 
	add_child(move_settings_node) 
	move_settings_node.set_owner(get_tree().get_edited_scene_root()) 
	move_settings_node.name = "Movement_Settings" #Then rename it for consistency.
	
	#Generates the Jump Settings tscn
	var jump_settings_node = jump_settings_scene.instantiate()
	add_child(jump_settings_node)
	jump_settings_node.set_owner(get_tree().get_edited_scene_root())
	jump_settings_node.name = "Jump_Settings"

#This handles default movement that can be called
func _move(delta):
	$Movement_Settings._execute_movement(delta) #This will run movement through the correct system
	move_and_slide() #Moves the character
	
	_update_direction() #This will update the direction of movement for the sprite
	
	_check_bounds() #This checks to see if the character is out of bounds

#This changes the direction of the character visually
func _update_direction():
	#It determines which direction that's wanted to update
	if directions_to_update["X"]: #This is the X axis (Left and Right)
		if velocity.x > 0: #If the character is moving Right then play right in the direction animation machine
			get_node("Action_Sprite")._update_animation("Right", "Direction")
		if velocity.x < 0:#If the character is moving Left then play left in the direction animation machine
			get_node("Action_Sprite")._update_animation("Left", "Direction")
	
	if directions_to_update["Y"]: #This is the Y Axis (Up and Down)
		if velocity.y < 0: #If the character is moving Up then play up in the direction animation machine
			get_node("Action_Sprite")._update_animation("Up", "Direction")
		if velocity.y > 0:#If the character is moving Down then play down in the direction animation machine
			get_node("Action_Sprite")._update_animation("Down", "Direction")

#This checks to see if the position of the character has left the world bounds decided on
func _check_bounds():
	if enable_boundaries["X-Bounds"]:
		if global_position.x < out_of_bounds["X-Bounds"][0] or global_position.x > out_of_bounds["X-Bounds"][1]:
			emit_signal("Out_Of_Bounds")
	
	if enable_boundaries["Y-Bounds"]:
		if global_position.y < out_of_bounds["Y-Bounds"][0] or global_position.y > out_of_bounds["Y-Bounds"][1]:
			emit_signal("Out_Of_Bounds")

