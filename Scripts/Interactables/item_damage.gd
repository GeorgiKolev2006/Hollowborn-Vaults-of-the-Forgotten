extends Area2D

@export var bonus_damage: float = 0.25

func _ready():
	connect("area_entered", Callable(self, "_on_area_entered"))

func _on_area_entered(area: Area2D) -> void:
	if area.name == "hitbox":
		var player = area.get_parent()
		if player.is_in_group("Player"):
			PlayerData.damage += bonus_damage  # 🛠️ FIXED: use PlayerData, not Player_data
			print("⚔️ Damage increased to: ", PlayerData.damage)
			queue_free()
