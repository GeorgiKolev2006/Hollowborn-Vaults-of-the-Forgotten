extends Area2D

@export var speed_boost: int = 15

func _ready():
	connect("area_entered", Callable(self, "_on_area_entered"))

func _on_area_entered(area: Area2D) -> void:
	if area.name == "hitbox":
		var player = area.get_parent()
		if player.is_in_group("Player") and PlayerData:
			PlayerData.Playerspeed += speed_boost
			print("🏃 Speed increased! New speed: ", PlayerData.Playerspeed)
			queue_free()
