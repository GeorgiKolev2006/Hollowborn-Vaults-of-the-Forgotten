extends Node

@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var sound_player: AudioStreamPlayer = $SoundPlayer

var current_music_path = "res://Assets/Sound/ambientmain_0.ogg"

func _ready():
	print("🔹 AudioManager Ready")
	if music_player == null:
		push_error("❌ ERROR: MusicPlayer node is NULL!")
		return
	play_music(current_music_path)

func play_music(path: String):
	if music_player == null:
		push_error("❌ ERROR: MusicPlayer is NULL! Cannot play music.")
		return

	if music_player.stream == null or music_player.stream.resource_path != path:
		var music_stream = load(path)
		if music_stream:
			music_player.stream = music_stream
			music_player.play()
			current_music_path = path
			print("✅ Playing music:", path)
		else:
			push_error("❌ ERROR: Music file not found at:", path)

func play_button_sound():
	if sound_player != null:
		sound_player.play()
	else:
		push_error("❌ ERROR: SoundPlayer is NULL! Cannot play button sound.")

func play_music_sound():
	if music_player != null:
		music_player.play()
	else:
		push_error("❌ ERROR: MusicPlayer is NULL! Cannot resume music.")
