extends Node

@onready var chara_controller = get_parent() #We get the Action! Character in-use
var move_node

@export_enum("Side-Scroller", "Free Move") var movement_type : int ##This determines if you can move top-down style or in a classic side-scroller style.

#This is a grouping of preset inputs
#You can type in your Action names to link them to these inputs
@export_group("Input Settings") 
@export var move_left_action : String
@export var move_right_action : String
@export var move_up_action : String
@export var move_down_action : String

@export var sprint_action : String

#These settings control how the character moves around
@export_group("Movement Settings") 
@export_enum("Instant", "Momentum") var movement_mode : int ##This dictates how your character will move around

@export var gravity : float ##This is how fast your character will fall
@export var gravity_fall_boost : float ##This is how much faster your character will fall if they're falling

@export var move_speed : float ##This is how fast the character will move or accelerate depending on the movement system.

@export_subgroup("Momentum Mode Settings")
@export var move_speed_max : float ##This is how fast the character can move at the most
@export var deceleration_factor : float ##This is how fast your character will decelerate 
@export var quick_turn_factor : float ##This is how fast your character will be able to switch directions


func _ready():
	await get_tree().create_timer(0.3).timeout #This gives all the other ready function variables a second to catch up
	
	move_node = chara_controller.movement_node #Then we assign the move node for later easy access

#This handles the gravity
func _apply_gravity(delta):
	var final_gravity = gravity #This is what gravity will be applied
	
	#If you don't want a weighted fall just set gravity boost to 0
	#If you don't want gravity set it to 0
	if not chara_controller.is_on_floor(): #If the character isn't on the floor
		if chara_controller.velocity.y > 0: #Then if the character is falling and not jumping
			final_gravity += gravity_fall_boost #Then we'll add the boost to gravity for a weighted fall
	
	#Here we apply gravity to the character
	chara_controller.velocity.y += final_gravity * delta

#This applies the movement to the character
func _execute_movement(delta):
	if move_node == null: return #If the move node isn't setup yet then we can't run this function
	 
	if movement_type == 0: #If it's a side-scroller
		_apply_gravity(delta) #We apply gravity
	
	if chara_controller.is_playable: #Then if it's a playable character we run the control code
		move_node._control_process(delta)


