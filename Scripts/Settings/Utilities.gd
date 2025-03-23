extends Node

@export var scenes: Array[PackedScene] = []
@export var scene_map: Dictionary = {}
@export var is_persistence: bool = false

const PATH = "user://settings.cfg"
var config = ConfigFile.new()

func _ready():
	config = ConfigFile.new()

	# Load existing config if available
	load_data()

	# Ensure controls are saved on first run
	for action in InputMap.get_actions():
		if InputMap.action_get_events(action).size() != 0:
			if !config.has_section_key("Controls", action):
				config.set_value("Controls", action, InputMap.action_get_events(action)[0])

	# Default video settings
	if !config.has_section("Video"):
		config.set_value("Video", "fullscreen", DisplayServer.WINDOW_MODE_WINDOWED)
		config.set_value("Video", "borderless", false)
		config.set_value("Video", "vsync", DisplayServer.VSYNC_ENABLED)

	# Default audio settings
	if !config.has_section("Audio"):
		for i in range(3):
			config.set_value("Audio", str(i), 0.5)

	if is_persistence:
		save_data()

# 🔹 **Save Configurations**
func save_data():
	if is_persistence:
		config.save(PATH)

# 🔹 **Load Configurations**
func load_data():
	if config.load(PATH) != OK:
		save_data()
		return
	load_control_settings()
	load_video_settings()

# 🔹 **Load Keybind Settings**
func load_control_settings():
	if config.has_section("Controls"):
		var keys = config.get_section_keys("Controls")
		for action in InputMap.get_actions():
			if keys.has(action):
				var value = config.get_value("Controls", action)
				InputMap.action_erase_events(action)
				InputMap.action_add_event(action, value)

# 🔹 **Load Video Settings**
func load_video_settings():
	if config.has_section("Video"):
		var screen_type = config.get_value("Video", "fullscreen", DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_mode(screen_type)

		var borderless = config.get_value("Video", "borderless", false)
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, borderless)

		var vsync_index = config.get_value("Video", "vsync", DisplayServer.VSYNC_ENABLED)
		DisplayServer.window_set_vsync_mode(vsync_index)

# 🔹 **Scene Management**
func switch_scene(scene_name: StringName, cur_scene: Node):
	if scene_name in scene_map:
		var scene = scenes[scene_map[scene_name]].instantiate()
		get_tree().root.add_child(scene)
		cur_scene.queue_free()

func hide_scene(scene):
	scene.hide()

func remove_scene(scene):
	get_tree().root.remove_child(scene)

func delete_scene(scene):
	scene.queue_free()
