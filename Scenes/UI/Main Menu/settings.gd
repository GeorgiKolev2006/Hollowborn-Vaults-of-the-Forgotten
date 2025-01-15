extends TabContainer

@export var main_menu_vbox: Node
@export var game_name: Node
@export var settings: TabContainer

func _ready():
	reload_settings()
	hide()

func reload_settings():
	pass

func _on_back_pressed() -> void:
	hide() 
	settings.hide()
	if main_menu_vbox:
		main_menu_vbox.show()
	else:
		print("Error: main_menu_vbox is null!")
	if game_name:
		game_name.show()
	else:
		print("Error: game_name is null!")
