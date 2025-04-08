extends Area2D

@export var damage: int = 0.5
@export var hit_cooldown: float = 1.0  # Cooldown time in seconds

var can_damage := true  # Flag to control when damage is allowed

func _ready():
	connect("area_entered", Callable(self, "_on_area_entered"))

func _on_area_entered(area: Area2D) -> void:
	print("Trap touched by:", area.name)  # ← debug log

	if can_damage and area.name == "hitbox":
		print("Player damage area detected!") 
		var player = area.get_parent()
		if player.has_method("take_damage"):
			can_damage = false
			player.take_damage(Vector2.ZERO)
			await get_tree().create_timer(hit_cooldown).timeout
			can_damage = true
