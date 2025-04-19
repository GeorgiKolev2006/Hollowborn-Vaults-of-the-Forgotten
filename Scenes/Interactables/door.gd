extends Node2D

@export var boss_node_path: NodePath
@export var next_scene_path: String = "res://Scenes/second_level.tscn"

var boss
@onready var sprite = $AnimatedSprite2D
@onready var area = $Area2D
@onready var area_collision = $Area2D/CollisionShape2D

var door_opened := false

func _ready():
	sprite.play("idle")
	area_collision.disabled = true

	boss = get_node_or_null(boss_node_path)
	if boss:
		if boss.has_signal("death"):
			boss.connect("death", Callable(self, "_on_boss_death"))
		else:
			set_process(true)

	# Connect door entry
	area.connect("body_entered", Callable(self, "_on_area_entered"))
	# Connect animation finished
	sprite.connect("animation_finished", Callable(self, "_on_animation_finished"))

func _process(_delta):
	if boss and boss.health <= 0:
		_on_boss_death()
		set_process(false)

func _on_boss_death():
	if not door_opened:
		sprite.play("open")
		door_opened = true  # Prevent double triggering

func _on_animation_finished():
	if sprite.animation == "open":
		sprite.play("opened_idle")
		area_collision.disabled = false  # Door now lets player in

func _on_area_entered(body):
	if body.is_in_group("Player"):
		get_tree().change_scene_to_file(next_scene_path)
