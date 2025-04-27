extends Node


static var SavePos: Vector2 = Vector2.ZERO
static var health: float = 4.0
static var max_health: float = 8.0
static var Playerspeed: int = 100
static var score: int = 0
static var coin: int = 0
static var damage: float = 1.0
static var current_level: int = 1  # 🆕 Level tracking

func UpdatePos(value: Vector2):
	SavePos += value

func save_to_firebase():
	var data = {
		"score": score,
		"coin": coin,
		"health": health,
		"SavePos": "%f,%f" % [SavePos.x, SavePos.y],
		"damage": damage,        # 🆕 Save attack damage
		"Playerspeed": Playerspeed,  # 🆕 Save player speed
		"current_level": current_level  # 🆕 Save current level
	}
	FireBase.put_data("player_data.json", data)

func load_from_firebase():
	FireBase.request_data("player_data.json", Callable(self, "_on_data_received"))

func _on_data_received(body):
	var data = JSON.parse_string(body.get_string_from_utf8())
	if data:
		score = data.get("score", 0)
		coin = data.get("coin", 0)
		health = data.get("health", 4)
		damage = data.get("damage", 1.0)
		Playerspeed = data.get("Playerspeed", 100)
		current_level = data.get("current_level", 1)

		if "SavePos" in data:
			var pos = data["SavePos"].split(",")
			SavePos = Vector2(float(pos[0]), float(pos[1]))
	else:
		print("⚠️ No data found in Firebase, starting fresh.")
		SavePos = Vector2(100, 200)

func delete_game():
	FireBase.delete_data("player_data.json")
