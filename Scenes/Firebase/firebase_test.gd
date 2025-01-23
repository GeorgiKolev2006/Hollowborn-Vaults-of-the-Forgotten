extends Node

# Replace with your Firebase Realtime Database URL
var database_url = "https://hollowborn-b4a1c-default-rtdb.europe-west1.firebasedatabase.app/"

func _ready():
	push_error("Starting Firebase write test...")  # Debugging message
	write_to_database("test/path", {"name": "Hollowborn", "status": "connected"})

func write_to_database(path: String, data: Dictionary):
	print("Starting database write...")  # Debugging message

	var url = database_url + path + ".json"
	var request = HTTPRequest.new()
	add_child(request)  # Add HTTPRequest to the scene

	print("HTTPRequest node added to scene.")  # Debugging message

	request.connect("request_completed", Callable(self, "_on_request_completed"))
	var error = request.request(url, [], HTTPClient.METHOD_PUT, JSON.stringify(data))

	if error != OK:
		print("Error making request: ", error)  # Debugging message
	else:
		print("HTTPRequest sent successfully.")  # Debugging message

func _on_request_completed(result, response_code, headers, body):
	push_error("Request completed with response code: " + str(response_code))  # Debugging message
	if response_code == 200:
		push_error("Data written successfully!")  # Confirm success
	else:
		push_error("Failed to write data. Response code: " + str(response_code))  # Debugging message

func save_game():
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		var player = players[0]
		var save_data = {
			"score": PlayerData.score,
			"coins": PlayerData.coin,
			"health": PlayerData.health,
			"SavePos": str(player.position.x) + "," + str(player.position.y)
			}
		write_to_database("players/player1", save_data)
		print("✅ Player data saved to Firebase:", save_data)
	else:
		push_error("❌ No player found when saving!")


# ✅ **Loads player data from Firebase**
func load_game():
	var url = database_url + "players/player1.json"
	var request = HTTPRequest.new()
	add_child(request)
	request.connect("request_completed", Callable(self, "_on_load_completed"))
	request.request(url)

func _on_load_completed(result, response_code, headers, body):
	if response_code == 200:
		var data = JSON.parse_string(body.get_string_from_utf8())
		if data:
			PlayerData.score = data.get("score", 0)
			PlayerData.coin = data.get("coins", 0)
			PlayerData.health = data.get("health", 4)

			if "SavePos" in data:
				var pos_string = data["SavePos"]
				var pos_split = pos_string.split(",")  
				if pos_split.size() == 2:  
					PlayerData.SavePos = Vector2(pos_split[0].to_float(), pos_split[1].to_float())
				else:
					print("⚠️ No save data found! Keeping default player position.")


					var players = get_tree().gept_nodes_in_group("Player")
					print("Players found:", players)
					if players.size() > 0:
						var player = players[0]
						player.position = PlayerData.SavePos
						print("✅ Player position set to:", PlayerData.SavePos)
					else:
						push_error("❌ No player found in 'Player' group! Check scene setup.")
		else:
				push_error("⚠️ No SavePos data found.")
	else:
		push_error("❌ Failed to load data from Firebase. Error:", response_code)

# Function to retrieve (GET) data from Firebase
func request_data(url: String, callback: Callable):
	var request = HTTPRequest.new()
	add_child(request)  
	request.connect("request_completed", callback)  
	var full_url = database_url + url + ".json"
	var error = request.request(full_url, [], HTTPClient.METHOD_GET)

	if error != OK:
		push_error("❌ Failed to request data from Firebase")
	else:
		print("✅ Data GET request sent successfully!")

# Function to store (PUT) data to Firebase
func put_data(url: String, data: Dictionary):
	var request = HTTPRequest.new()
	add_child(request)  
	request.connect("request_completed", Callable(self, "_on_request_completed"))  

	var full_url = database_url + url + ".json"
	var headers = ["Content-Type: application/json"]
	var json_data = JSON.stringify(data)

	var error = request.request(full_url, headers, HTTPClient.METHOD_PUT, json_data)

	if error != OK:
		push_error("❌ Failed to PUT data to Firebase")
	else:
		print("✅ Data PUT request sent successfully!")

func delete_game():
	var url = "players/player1.json"  # Path to the saved data
	var request = HTTPRequest.new()
	add_child(request)
	request.connect("request_completed", Callable(self, "_on_delete_completed"))
	var error = request.request(database_url + url, [], HTTPClient.METHOD_DELETE)

	if error != OK:
		push_error("❌ Failed to delete data from Firebase")
	else:
		print("✅ Save data deletion request sent successfully!")

func _on_delete_completed(result, response_code, headers, body):
	if response_code == 200:
		print("✅ Save data deleted successfully!")
	else:
		push_error("❌ Failed to delete save data. Response code: " + str(response_code))
