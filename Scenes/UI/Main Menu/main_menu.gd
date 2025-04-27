extends Control

@onready var settings: TabContainer = $settings
@onready var main_menu_vbox = $mainmenuvbox
@onready var game_name = $GameName
@onready var charct = $CharacterMenu

func _ready() -> void:
	main_menu_vbox.grab_focus()

func _on_options_pressed() -> void:
	main_menu_vbox.hide()
	game_name.hide()
	settings.show()
	settings.current_tab = 0

func _on_tutorial_pressed() -> void:
	if FireBase:
		FireBase.firebase_enabled = false  # 🚫 Disable Firebase manually
		print("🔥 Firebase disabled for tutorial")
	get_tree().change_scene_to_file("res://Scenes/Levels/tutorial.tscn")

func _on_back_pressed() -> void:
	settings.hide()
	main_menu_vbox.show()
	game_name.show()

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/GUI/CharacterMenu.tscn")
	# get_tree().change_scene_to_file("res://Scenes/Levels/main_level.tscn")  # if you want direct to level

func _on_quit_pressed() -> void:
	get_tree().quit()
