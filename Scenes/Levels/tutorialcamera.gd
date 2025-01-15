extends Camera2D

@onready var player: CharacterBody2D = get_node("../Player")
@onready var tilemap: TileMap = get_node("../Ground")

func _ready():
	if not tilemap:
		print("Error: TileMap not found!")
		return

	if not tilemap.tile_set:
		print("Error: TileMap has no TileSet assigned!")
		return

	var tile_size = tilemap.tile_set.tile_size
	var map_rect = tilemap.get_used_rect()
	var world_size = map_rect.size * tile_size

	limit_right = world_size.x
	limit_bottom = world_size.y

func _process(delta: float):
	position = player.position
