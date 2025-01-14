extends TabContainer

@export var main_menu: Node

func _ready():
	reload_settings()
	hide()

func reload_settings():
	pass

func _on_back_pressed():
	hide() 
	if main_menu:
		if main_menu.has_node("VBoxContainer"):
			main_menu.get_node("VBoxContainer").show()
		if main_menu.has_node("GameName"):
			main_menu.get_node("GameName").show()
