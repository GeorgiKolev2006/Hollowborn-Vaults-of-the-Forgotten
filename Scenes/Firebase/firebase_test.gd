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
