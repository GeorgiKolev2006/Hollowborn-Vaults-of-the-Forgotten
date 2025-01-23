extends Node
class_name Player_data


@export var score = 0
@export var Playerspeed = 70
@export var coin = 0
@export var health = 4
@export var SavePos: Vector2 = Vector2.ZERO

func UpdatePos(value : Vector2):
	SavePos += value


func save_to_firebase():
	var data = {
		"score": score,
		"coin": coin,
		"health": health,
		"SavePos": SavePos 
		}
	var url = "player_data.json" 
	FireBase.put_data(url, data) 

func load_from_firebase():
	var url = "player_data.json"
	FireBase.request_data(url, Callable(self, "_on_data_received"))

func _on_data_received(result, response_code, data):
	if response_code == 200:
		if data:
			score = data.get("score", 0)
			coin = data.get("coin", 0)
			health = data.get("health", 4)
			SavePos = data.get("SavePos", Vector2.ZERO)
			print("✅ Loaded data from Firebase:", data)
		else:
			print("⚠️ No data found in Firebase, starting fresh.")
	else:
		print("❌ Failed to load data. Error:", response_code)

func _ready():
	load_from_firebase()

func _process(delta):
	if Input.is_action_just_pressed("save_game"):
		save_to_firebase()
