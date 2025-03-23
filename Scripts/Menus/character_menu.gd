extends Control

@onready var load_buttons = [$Panel/VBoxContainer1/Load1, $Panel/VBoxContainer2/Load2, $Panel/VBoxContainer3/Load3, $Panel/VBoxContainer4/Load4]
@onready var delete_buttons = [$Panel/VBoxContainer1/Delete1, $Panel/VBoxContainer2/Delete2, $Panel/VBoxContainer3/Delete3, $Panel/VBoxContainer4/Delete4]
@onready var create_buttons = [$Create1, $Create2, $Create3, $Create4]
@onready var back_button = $Back

var selected_save = ""
var save_slots = ["player1", "player2", "player3", "player4"]

# Called when the scene is ready
func _ready():
	# Dynamically connect buttons to actions
	for i in range(load_buttons.size()):
		load_buttons[i].connect("pressed", Callable(self, "_on_load_pressed").bind(i))
		create_buttons[i].connect("pressed", Callable(self, "_on_create_pressed").bind(i))
		delete_buttons[i].connect("pressed", Callable(self, "_on_delete_pressed").bind(i))
		# Check if save exists and update the UI
		_check_save_slot(i)

	# Connect the back button to its handler
	back_button.connect("pressed", Callable(self, "_on_back_pressed"))

# ✅ Load game when a save slot is selected
func _on_load_pressed(index):
	selected_save = "players/" + save_slots[index]
	# Await Firebase data request
	FireBase.request_data(selected_save, Callable(self, "_on_load_completed").bind(index))

# ✅ Create a new save slot
func _on_create_pressed(index):
	selected_save = "players/" + save_slots[index]
	var new_save_data = {
		"score": 0,
		"coins": 0,
		"health": 4,
		"SavePos": "100,200"  # Default starting position
	}
	# Await Firebase save operation
	FireBase.put_data(selected_save, new_save_data)
	print("✅ Created new save slot:", selected_save)
	_check_save_slot(index)  # Update button visibility immediately

# ✅ Delete a save slot
func _on_delete_pressed(index):
	selected_save = "players/" + save_slots[index]
	# Await Firebase delete operation
	FireBase.delete_game(selected_save)
	print("🗑️ Deleted save slot:", selected_save)
	_check_save_slot(index)  # Update button visibility immediately

# ✅ Check if a save exists in Firebase and update UI
func _check_save_slot(index):
	var save_path = "players/" + save_slots[index]
	FireBase.request_data(save_path, Callable(self, "_on_check_save").bind(index))

# ✅ Check save slot data (Firebase callback)
func _on_check_save(body, index):
	var data = JSON.parse_string(body.get_string_from_utf8())
	if data:
		# Save exists
		load_buttons[index].visible = true
		delete_buttons[index].visible = true
		create_buttons[index].visible = false
	else:
		# No save
		load_buttons[index].visible = false
		delete_buttons[index].visible = false
		create_buttons[index].visible = true

# ✅ After loading data, transition to the game
func _on_load_completed(body, index):
	var data = JSON.parse_string(body.get_string_from_utf8())
	if data:
		PlayerData.score = data.get("score", 0)
		PlayerData.coin = data.get("coins", 0)
		PlayerData.health = data.get("health", 4)

		if "SavePos" in data:
			var pos_split = data["SavePos"].split(",")
			if pos_split.size() == 2:
				PlayerData.SavePos = Vector2(pos_split[0].to_float(), pos_split[1].to_float())

		print("✅ Save Loaded. Starting game...")
		# Scene change after the data is loaded
		await get_tree().change_scene_to_file("res://Scenes/Levels/main_level.tscn")  # Change scene
	else:
		push_error("⚠️ No data found in save slot!")
