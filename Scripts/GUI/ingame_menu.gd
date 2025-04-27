extends CanvasLayer

@onready var resume_btn = $Panel/Resume
@onready var save_btn = $Panel/Save
@onready var load_btn = $Panel/LastSave
@onready var main_menu_btn = $Panel/MainMenu
@onready var quit_btn = $Panel/Quit

var is_paused := false

func _ready():
	print("Menu script loaded")
	visible = false

	resume_btn.pressed.connect(_on_resume_pressed)
	save_btn.pressed.connect(_on_save_pressed)
	load_btn.pressed.connect(_on_load_pressed)
	main_menu_btn.pressed.connect(_on_main_menu_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)

func _unhandled_input(event):
	if event.is_action_pressed("ui_menus"):
		toggle_menu()
		get_viewport().set_input_as_handled()

func toggle_menu():
	is_paused = not is_paused
	visible = is_paused

	var player = get_parent().get_node_or_null("Player")
	if player:
		player.set_process(not is_paused)
		player.set_physics_process(not is_paused)

func _on_resume_pressed():
	toggle_menu()

func _on_save_pressed():
	var player = get_parent().get_node_or_null("Player")
	if player:
		player.save_game()
		print("Game saved from menu.")

func _on_load_pressed():
	var player = get_parent().get_node_or_null("Player")
	if player:
		player.load_game()
		print("Game loaded from menu.")

func _on_main_menu_pressed():
	print("Returning to main menu")
	get_tree().paused = false
	var main_scene = load("res://Scenes/UI/Main Menu/main_menu.tscn").instantiate()
	get_tree().root.call_deferred("add_child", main_scene)
	get_tree().current_scene.queue_free()

func _on_quit_pressed():
	print("Quitting game")
	get_tree().quit()
