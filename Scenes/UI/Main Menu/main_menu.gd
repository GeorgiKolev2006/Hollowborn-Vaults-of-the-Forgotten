extends Control

@onready var settings1: = preload("res://Scenes/UI/Main Menu/settings.tscn")
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
	if settings == null:
		var settings_scene = load("res://Scenes/UI/Main Menu/settings.tscn").instantiate()
		settings = settings_scene.get_node("Settings")
		add_child(settings_scene)
	settings.show()
	settings.current_tab = 0
	settings.get_tab_at_index(settings.current_tab).grab_focus()
