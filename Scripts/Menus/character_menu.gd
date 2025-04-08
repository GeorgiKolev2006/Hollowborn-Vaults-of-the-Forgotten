extends Control

# Button references with explicit typing
@onready var load_buttons: Array[Button] = [
	$Panel/VBoxContainer1/Load1,
	$Panel/VBoxContainer2/Load2,
	$Panel/VBoxContainer3/Load3,
	$Panel/VBoxContainer4/Load4
]

@onready var delete_buttons: Array[Button] = [
	$Panel/VBoxContainer1/Delete1,
	$Panel/VBoxContainer2/Delete2,
	$Panel/VBoxContainer3/Delete3,
	$Panel/VBoxContainer4/Delete4
]

@onready var create_buttons: Array[Button] = [
	$Create1,
	$Create2,
	$Create3,
	$Create4
]

# Explicitly typed variables
var save_slots: Array[String] = ["player1", "player2", "player3", "player4"]
var selected_save: String = ""

func _ready():
	# Wait for nodes to initialize
	await get_tree().process_frame
	
	# Connect all buttons with safety checks
	for i in range(4):
		if load_buttons[i]:
			load_buttons[i].pressed.connect(_on_load_pressed.bind(i))
		if delete_buttons[i]:
			delete_buttons[i].pressed.connect(_on_delete_pressed.bind(i))
		if create_buttons[i]:
			create_buttons[i].pressed.connect(_on_create_pressed.bind(i))
		
		# Initial check for existing saves
		_check_save_slot(i)

func _on_load_pressed(index: int):
	selected_save = "players/" + save_slots[index]
	FireBase.request_data(selected_save, Callable(self, "_on_load_completed"))

func _on_create_pressed(index: int):
	selected_save = "players/" + save_slots[index]
	var new_save_data: Dictionary = {
		"score": 0,
		"coins": 0,
		"health": 4,
		"SavePos": "100,200"
	}
	
	# Create save and force UI update
	FireBase.put_data(selected_save, new_save_data)
	await get_tree().create_timer(0.5).timeout  # Small delay for Firebase
	_check_save_slot(index)  # Re-check this slot

func _on_delete_pressed(index: int):
	selected_save = "players/" + save_slots[index]
	FireBase.delete_data(selected_save)
	await get_tree().create_timer(0.5).timeout  # Small delay for Firebase
	_check_save_slot(index)  # Re-check this slot

func _check_save_slot(index: int):
	var save_path: String = "players/" + save_slots[index]  # Explicit String type
	FireBase.request_data(save_path, Callable(self, "_on_check_save").bind(index))

func _on_check_save(body: PackedByteArray, index: int):
	var data = JSON.parse_string(body.get_string_from_utf8())
	
	# Update button visibility
	if data:  # Save exists
		load_buttons[index].visible = true
		delete_buttons[index].visible = true
		create_buttons[index].visible = false
	else:  # No save
		load_buttons[index].visible = false
		delete_buttons[index].visible = false
		create_buttons[index].visible = true

func _on_load_completed(body: PackedByteArray):
	var data = JSON.parse_string(body.get_string_from_utf8())
	if data:
		Player_data.score = data.get("score", 0)
		Player_data.coin = data.get("coins", 0)
		Player_data.health = data.get("health", 4)
		if "SavePos" in data:
			var pos_split: PackedStringArray = data["SavePos"].split(",")
			if pos_split.size() == 2:
				Player_data.SavePos = Vector2(pos_split[0].to_float(), pos_split[1].to_float())
		get_tree().change_scene_to_file("res://Scenes/Levels/main_level.tscn")
