extends Node

@onready var http_request : HTTPRequest = $HTTPRequest  # Ensure this path is correct

var callback : Callable

# Initialize HTTPRequest node and connect the signal
func _ready():
	if http_request:
		# Connect the request_completed signal to the _on_request_completed method
		http_request.connect("request_completed", Callable(self, "_on_request_completed"))
	else:
		push_error("HTTPRequest node not found in the scene.")

# ✅ Function to request data from Firebase
func request_data(path, callback_method):
	if not http_request:
		push_error("HTTPRequest node is null.")
		return
	
	var url = "https://hollowborn-b4a1c-default-rtdb.europe-west1.firebasedatabase.app/" + path + ".json"
	var error = http_request.request(url)
	if error != OK:
		push_error("Failed to request data from Firebase.")
	else:
		# Store the callback method as a callable to be used when the request is completed
		callback = callback_method

# ✅ Callback for when HTTPRequest is completed
func _on_request_completed(result, response_code, headers, body):
	if response_code == 200:
		# Call the stored callback method with the response data
		if callback:
			callback.call(body)
	else:
		push_error("Failed to load data from Firebase. Response code: " + str(response_code))
