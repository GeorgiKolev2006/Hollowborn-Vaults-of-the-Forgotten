@tool
extends Node2D

func _ready():
	if Engine.is_editor_hint():
		setup()

#This handles setting up the 
func setup():
	if get_child_count() != 0: #If there is already a setup sprite
		for child in get_children(): #We run through each one
			child.queue_free() #Then delete them
		await get_tree().create_timer(0.1).timeout #This is a buffer between removing and adding similar nodes to avoid naming issues.
	
	var essentials = get_parent().action_sprite_essentials.instantiate() #We get an instance of the essentials
	add_child(essentials) #Add essentials as a child
	essentials.set_owner(get_tree().get_edited_scene_root()) #Then we set ownership
	essentials.name = "Essentials" #Then we rename it

#This handles updating animations
func _update_animation(_anim_name, _anim_machine):
	var animator = get_child(0).get_node("Machines/"+_anim_machine) #We first get the right animation machine
	
	#If the animator has the animation then we play it
	if animator.has_animation(_anim_name):
		animator.play(_anim_name)

