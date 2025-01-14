extends Control

@onready var settings: TabContainer = $Settings 

func _ready() -> void:
	$VBoxContainer/Start.grab_focus() 

func _process(delta: float) -> void:
	pass

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/main_level.tscn")  

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_options_pressed() -> void:
	$VBoxContainer.hide()
	$GameName.hide()
	settings.show()
	settings.current_tab = 0 
