extends Node
class_name Player_data

static var SavePos: Vector2 = Vector2.ZERO
static var health: int = 4
static var Playerspeed: int = 100
static var score: int = 0
static var coin: int = 0

# Update the player's position (used in some game mechanics)
func UpdatePos(value: Vector2):
	SavePos += value

# Save player data to Firebase
func save_to_firebase():
	var data = {
		"score": score,
		"coin": coin,
		"health": health,
		"SavePos": SavePos
	}
	var url = "player_data.json"
	Firebase.put_data(url, data)

# Load player data from Firebase
func load_from_firebase():
	var url = "player_data.json"
	Firebase.request_data(url, Callable(self, "_on_data_received"))

# Callback for handling data when it is received from Firebase
func _on_data_received(result, response_code, data):
	if response_code == 200:
		if data:
			score = data.get("score", 0)
			coin = data.get("coin", 0)
			health = data.get("health", 4)
			SavePos = data.get("SavePos", Vector2.ZERO)
		else:
			print("⚠️ No data found in Firebase, starting fresh.")
			SavePos = Vector2(100, 200)  # Default position if no save exists
	else:
		print("❌ Failed to load data. Error:", response_code)

# Delete the game data from Firebase
func delete_game():
	var url = "player_data.json"
	Firebase.delete_data(url)
