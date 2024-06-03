extends Node2D

@onready var tile_map = $TileMap

var background = 0
var foreground = 1
var grass_dirt = Vector2i(0, 0)

func _ready():
	tile_map.set_cell(foreground, Vector2i(1, 3), 0, grass_dirt)
	print_debug("elo")