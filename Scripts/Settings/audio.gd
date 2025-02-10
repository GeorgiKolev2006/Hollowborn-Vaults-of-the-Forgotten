extends TabBar

@onready var master: HSlider = $HBoxContainer/VBoxContainer2/Master
@onready var music: HSlider = $HBoxContainer/VBoxContainer2/Music
@onready var sound_effect: HSlider = $HBoxContainer/VBoxContainer2/SoundEffects

func _ready():
	load_audio_settings()

func load_audio_settings():
	master.value = UtilitiesData.config.get_value("Audio", '0')
	AudioServer.set_bus_volume_db(0, linear_to_db(master.value))
	music.value = UtilitiesData.config.get_value("Audio", '1')
	AudioServer.set_bus_volume_db(0, linear_to_db(music.value))
	sound_effect.value = UtilitiesData.config.get_value("Audio", '2')
	AudioServer.set_bus_volume_db(0, linear_to_db(sound_effect.value))

func _on_master_value_changed(value):
	set_volume(0, value)

func _on_music_value_changed(value):
	set_volume(1, value)

func _on_sound_effects_value_changed(value):
	set_volume(2, value)

func set_volume(idx, value):
	if idx >= AudioServer.bus_count:  # ✅ Ensure index is valid
		push_error("❌ ERROR: Bus index", idx, "is out of bounds! (buses.size() =", AudioServer.bus_count, ")")
		return
	AudioServer.set_bus_volume_db(idx, linear_to_db(value))
	UtilitiesData.config.set_value("Audio", str(idx), value)
	UtilitiesData.save_data()
	AudioManager.play_button_sound()
