extends TabContainer

@onready var main_menu_vbox: Node = get_parent().get_node("mainmenuvbox")
@onready var game_name: Node = get_parent().get_node("GameName")
@onready var fullscreen_checkbox = $Video/HBoxContainer/VBoxContainer2/Fullscreen
@onready var master_volume_slider = $Audio/HBoxContainer/VBoxContainer2/Master
@onready var music_volume_slider = $Audio/HBoxContainer/VBoxContainer2/Music

func _ready():
	reload_settings()
	hide() 
	var video_settings = ConfigFileHandler.load_video_settings()
	
	var audio_settings = ConfigFileHandler.load_audio_settings()
	master_volume_slider.value = min(audio_settings.get("master_volume", 1.0), 1.0) * 100
	music_volume_slider.value = min(audio_settings.get("music_volume", 1.0), 1.0) * 100



func reload_settings():
	pass

func _on_back_pressed() -> void:
	hide()  # Hide the settings
	if main_menu_vbox:
		main_menu_vbox.show()  # Show main menu vbox
	else:
		print("Error: main_menu_vbox is null!")
	if game_name:
		game_name.show()  # Show game name
	else:
		print("Error: game_name is null!")


func _on_fullscreen_toggled(toggled_on: bool) -> void:
	ConfigFileHandler.save_video_settings("fullscreen", toggled_on)


func _on_borderless_toggled(toggled_on: bool) -> void:
	ConfigFileHandler.save_video_settings("borderless", toggled_on)


func _on_vsync_item_selected(index: int) -> void:
	ConfigFileHandler.save_video_settings("V-sync", index)


func _on_master_drag_ended(value_changed: bool) -> void:
	if value_changed:
		var selected_tab = $TabContainer.get_selected_tab()
		var master_slider = selected_tab.get_node("HBoxContainer/VBoxContainer2/Master")
		ConfigFileHandler.save_audio_settings("master_volume", master_slider.value / 100.0)


func _on_music_drag_ended(value_changed: bool) -> void:
	if value_changed:
		var selected_tab = $TabContainer.get_selected_tab()
		var music_slider = selected_tab.get_node("HBoxContainer/VBoxContainer2/Music")
		ConfigFileHandler.save_audio_settings("music_volume", music_slider.value / 100.0)

func _on_sound_effects_drag_ended(value_changed: bool) -> void:
	if value_changed:
		var selected_tab = $TabContainer.get_selected_tab()
		var sfx_slider = selected_tab.get_node("HBoxContainer/VBoxContainer2/SoundEffects")
		ConfigFileHandler.save_audio_settings("sfx_volume", sfx_slider.value / 100.0)
