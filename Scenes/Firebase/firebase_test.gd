extends Node

var http_request: HTTPRequest
var callback = null
var firebase_enabled: bool = true  # 🔥 Added this

func _ready():
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)

func request_data(path: String, callback_method: Callable):
	if not firebase_enabled:
		print("🚫 Firebase request blocked: request_data")
		return
	if not http_request:
		push_error("HTTPRequest node is not ready.")
		return
	
	var url = "https://hollowborn-b4a1c-default-rtdb.europe-west1.firebasedatabase.app/" + path + ".json"
	var error = http_request.request(url)
	if error != OK:
		push_error("Failed to request data from Firebase.")
	else:
		callback = callback_method

func put_data(path: String, data: Dictionary):
	if not firebase_enabled:
		print("🚫 Firebase request blocked: put_data")
		return
	if not http_request:
		push_error("HTTPRequest node is not ready.")
		return
	
	var url = "https://hollowborn-b4a1c-default-rtdb.europe-west1.firebasedatabase.app/" + path + ".json"
	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify(data)
	var error = http_request.request(url, headers, HTTPClient.METHOD_PUT, body)
	if error != OK:
		push_error("Failed to put data to Firebase.")

func delete_data(path: String):
	if not firebase_enabled:
		print("🚫 Firebase request blocked: delete_data")
		return
	if not http_request:
		push_error("HTTPRequest node is not ready.")
		return
	
	var url = "https://hollowborn-b4a1c-default-rtdb.europe-west1.firebasedatabase.app/" + path + ".json"
	var error = http_request.request(url, [], HTTPClient.METHOD_DELETE)
	if error != OK:
		push_error("Failed to delete data from Firebase.")

func _on_request_completed(result, response_code, headers, body):
	if callback:
		callback.call(body)
