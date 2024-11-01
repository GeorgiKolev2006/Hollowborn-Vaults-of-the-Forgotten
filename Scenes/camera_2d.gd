extends Camera2D

@export var player: CharacterBody2D
@export var tilemap: TileMap

func _ready():
	var tile_size = tilemap.tile_set.tile_size
	var map_rect = tilemap.get_used_rect()
	var world_size = map_rect.size * tile_size

	limit_right = world_size.x
	limit_bottom = world_size.y

func _process(delta):
	position = player.position
