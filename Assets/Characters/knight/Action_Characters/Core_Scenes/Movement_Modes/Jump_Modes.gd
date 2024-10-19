extends Node

#NOTES#
#I keep most of the core code in here due to it being basic functionality so it keeps redudant code low
#and should also make it easier to create custom modes and logic; plus these aren't 100% needed you could always
#put these functions inside your own custom mode and make it work how these did originally.

#Functions like Lose and Gain jump could be condensed but I kept them their own thing in case you want to do something custom
#with each of them like trigger a signal for a sound or visual cue.

signal Landed

@onready var chara_controller = get_parent() #The Action! Character for reference
var jump_node #This is the jump node we'll be using as reference
var coyote_timer : Timer #This holds the timer used for coyote time jumps

#This is a grouping of preset inputs
#You can type in your Action names to link them to these inputs
@export_group("Input Settings") 
@export var jump_action : String

#These settings control how the character jumps
@export_group("Jump Settings")
@export_enum("Fixed", "Variable") var jump_mode : int ##This dictates how your character will jump around

@export var jump_count : int ##This is the total amount of times the character can jump
@onready var jump_count_play = jump_count #This is how many times the character can currently jump. This will be the changing counter.
@export var jump_power : float ##This is how much power a jump has behind it. For some systems it's the initial jump's power.

var in_air = false #This tells the code whether or not the character was in the air the last tick
@export var can_jump_in_air : bool ##This dictates whether or not the character can jump in the air
@export var coyote_time : float ##If you can't air jump this is how long the character be in the air before they can't jump.
var coyote_jump_available = true #This dictates whether the character can coyote_jump
@export_enum("Arcade", "Realistic-ish") var jump_physics : int ##This is how the jump physics will work.

@export_subgroup("Variable Jump Settings")
@export var jump_power_variable : float ##This is how much power a continued or a variable jump will have.
@export var jump_duration : float ##This is how long a continued or a variable jump can occur.
@onready var jump_time_left = jump_duration #This is how much time the character has left in their jump.


#This will setup a few basics on ready
func _ready():
	await get_tree().create_timer(0.3).timeout #We take a second here to make sure any onready variable has had time to setup
	
	jump_node = chara_controller.jump_node #This sets the jump node we'll be using for reference later
	setup_coyote_jump() #This sets up the coyote jump logic

#This is used to apply any force to the character whether it's a jump, damage boop; or a bounce.
func apply_force(_force, _direction):
	var force_applied = _force * _direction #This is the force we'll apply to the character
	
	#If the jump physics is set to Arcade
	if jump_physics == 0:
		#If the character is falling we set the velocity Y to 0 so it doesn't take away from the jump
		if chara_controller.velocity.y > 0: 
			chara_controller.velocity.y = 0
	
	chara_controller.velocity += force_applied #Then we apply the force to the character body

#This handles Landing
func landed():
	coyote_jump_available = true #Coyote jump is true now that we've landed and it resets
	in_air = false #They're no longer in the air.
	
	reset_jumps() #Reset jump count to max amounts
	reset_jump_time() #Resets the jump time (Only applicable for Variable jump out of the box)
	
	emit_signal("Landed") #Signal landing

#This handles checking if the character can jump
func can_jump():
	if jump_count_play > 0: #We check if they have jumps left
		if chara_controller.is_on_floor(): #Then we check if they're on the floor
			return true #If they are then this is instantly good to jump!
		
		if not chara_controller.is_on_floor(): #If they're not on the floor
			if can_jump_in_air or coyote_jump_available: #If they can air jump or can coyote jump
				return true #Then they can still jump!
			
			elif jump_node.name in ["Variable"] and jump_node.variable_jump_available and jump_mode == 1: #If it's a variable jump
				return true
	
	return false #For any other case they can't jump

#This handles resetting the jump time
func reset_jump_time():
	jump_time_left = jump_duration

#This handles resetting the amount of jumps you have
func reset_jumps():
	jump_count_play = jump_count

#This takes away a jump
func lose_jump():
	jump_count_play -= 1

#This adds a jump
func gain_jump():
	jump_count_play = clampi(jump_count_play + 1, 0, jump_count)

#This handles seeing if we've landed or not
func landing_check():
	if chara_controller.is_on_floor(): #If the character is on the floor
		if in_air: #Check to see if they were in the air last tick
			landed() #If they were then we'll call landed

#This sets up the coyote jump logic
func setup_coyote_jump():
	#This checks if coyote time is being used (Coyote time is useless if you can air jump)
	if coyote_time > 0:
		coyote_timer = Timer.new() #We create a new timer
		coyote_timer.autostart = false #We make sure autostart isn't on
		add_child(coyote_timer) #We add the timer to the jump node
		coyote_timer.timeout.connect(end_coyote_time) #Then we connect the timeout signal to end coyote time
		coyote_timer.wait_time = coyote_time #Finally we set the wait time to coyote time

#This checks to see if we can still coyote jump or if the timer needs to start
func coyote_jump_check():
	if not chara_controller.is_on_floor(): #If the character isn't on the floor
		in_air = true #Then they're in the air
		if not can_jump_in_air: #If the character can't air jump
			if coyote_timer != null: #If coyote timer exists
				if coyote_timer.time_left == 0: #Then we check to see if it's currently running
					coyote_timer.start() #If not then we start it

#This handles coyote time's ending
func end_coyote_time():
	#Once the time cut off has occured
	coyote_jump_available = false #You can no longer coyote time jump

