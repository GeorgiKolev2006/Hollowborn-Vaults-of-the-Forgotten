extends Area2D

@onready var anim = $AnimatedSprite2D
@onready var label = $Label
@onready var coin_icon = $TextureRect
@onready var collision_shape = $CollisionShape2D

@export var coin_cost := 5
var is_opened := false

func _ready():
	label.visible = false
	coin_icon.visible = false
	anim.play("idle-unopened")

func _on_area_entered(area):
	if is_opened:
		return

	if area.name == "sword" or area.is_in_group("Sword"):
		if Player_data.coin >= coin_cost:
			Player_data.coin -= coin_cost
			open_chest()
		else:
			show_price_hint()

func open_chest():
	is_opened = true
	anim.play("opening")
	await anim.animation_finished
	anim.play("idle-opened")
	label.visible = false
	coin_icon.visible = false
	collision_shape.disabled = true  # Optional if you want to disable future interactions

func show_price_hint():
	label.visible = true
	coin_icon.visible = true
	# Optional: Hide after a second
	await get_tree().create_timer(1.5).timeout
	if not is_opened:
		label.visible = false
		coin_icon.visible = false
