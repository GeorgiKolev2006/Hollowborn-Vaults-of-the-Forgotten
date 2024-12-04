extends Control

func _ready() -> void:
	$VBoxContainer/Start.grab_focus()

func _process(delta: float) -> void:
	pass


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/main_level.tscn")


func _on_options_pressed() -> void:
	var options_scene = load("res://Scenes/UI/Options/options.tscn").instantiate()
	add_child(options_scene)
	options_scene.set_position(Vector2.ZERO) 


func _on_quit_pressed() -> void:
	get_tree().quit()
