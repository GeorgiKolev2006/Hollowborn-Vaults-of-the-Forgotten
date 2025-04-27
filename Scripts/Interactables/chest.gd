extends StaticBody2D

@onready var anim = $AnimatedSprite2D
@onready var label = $Label
@onready var coin_icon = $TextureRect  # Adjust if you're using TextureRect
@onready var collision_shape = $CollisionShape2D
@onready var hitbox = $hitbox  # Area2D used to detect sword hit

@export var coin_cost := 0
@export var item_movement_scene: PackedScene
@export var item_damage_scene: PackedScene

var is_opened := false

func _ready():
	label.visible = true
	coin_icon.visible = true
	anim.play("idle-unopened")

	if hitbox:
		hitbox.connect("area_entered", Callable(self, "_on_area_entered"))
	else:
		print("⚠️ Hitbox (Area2D) not found!")

func _on_area_entered(area: Area2D):
	if is_opened:
		return

	if area.name == "sword" or area.is_in_group("Sword"):
		if PlayerData.coin >= coin_cost:
			PlayerData.coin -= coin_cost
			is_opened = true
			open_chest()

func open_chest():
	anim.play("opening")
	await anim.animation_finished
	anim.play("idle-opened")

	label.visible = false
	coin_icon.visible = false
	collision_shape.set_deferred("disabled", true)

	# 🎲 Randomly drop an item
	randomize()
	var rng = randi_range(1, 2)

	var loot = null
	if rng == 1 and item_movement_scene:
		loot = item_movement_scene.instantiate()
	elif rng == 2 and item_damage_scene:
		loot = item_damage_scene.instantiate()

	if loot:
		loot.global_position = global_position
		get_tree().current_scene.add_child(loot)
