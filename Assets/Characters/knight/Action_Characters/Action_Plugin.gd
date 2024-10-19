@tool
extends EditorPlugin

#Thanks for trying out Action! Characters!
#If you have any issues make sure to check out the Documentation that holds a ton of great info!
#It even includes tutorials!

func _enter_tree():
	#This creates the ActionCharacter node
	add_custom_type("ActionCharacter", "CharacterBody2D", preload("Action_Character.gd"), preload("Icons/ActionBody_Icon.png"))

#Make sure all custom nodes are removed with the custom type
func _exit_tree():
	remove_custom_type("ActionCharacter")
