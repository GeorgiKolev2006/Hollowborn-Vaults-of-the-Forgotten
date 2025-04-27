extends Node2D

@export var boss_node_path: NodePath
@export var next_scene_path: String = "res://Scenes/Levels/second_level.tscn"

var boss: Node = null
var door_opened := false

@onready var sprite = $AnimatedSprite2D
@onready var area = $Area2D
@onready var area_collision = $Area2D/CollisionShape2D

func _ready():
	sprite.play("idle")
	area_collision.disabled = true  # Door blocked at start

	# --- Find the boss ---
	if boss_node_path != NodePath(""):
		boss = get_node_or_null(boss_node_path)

	if not boss:
		boss = get_tree().get_root().find_child("Golem", true, false)  # <- This is important now

	if boss:
		if boss.has_signal("died"):
			boss.connect("died", Callable(self, "_on_boss_death"))
			print("✅ Connected to Boss death signal!")
		else:
			print("⚠️ Boss found but missing 'died' signal.")
	else:
		print("❌ Boss not found at all.")

	# Connect door entry and animation finished signals
	area.body_entered.connect(_on_area_entered)
	sprite.animation_finished.connect(_on_animation_finished)


func _on_boss_death():
	if not door_opened:
		print("🚪 Door opening triggered by boss death.")
		door_opened = true
		sprite.play("open")

func _on_animation_finished():
	if sprite.animation == "open":
		sprite.play("opened_idle")
		area_collision.disabled = false  # Allow player through

func _on_area_entered(body: Node):
	if body.is_in_group("Player") and door_opened:
		print("🎉 Player entered the door.")
		get_tree().change_scene_to_file(next_scene_path)
