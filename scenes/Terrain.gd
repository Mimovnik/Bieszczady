extends Node2D

@onready var tile_map = $TileMap

var background = 0
var foreground = 1

var grass_dirt = Vector2i(0, 0)
var dirt = Vector2i(0, 1)

var width: int = 100
var height: int = 100

var noise: FastNoiseLite = null

@export
var frequency: float

@export
var noise_seed: int

@export
var cave_threshold: float

func _ready():
	generate_noise()

	for y in range(height):
		for x in range(width):
			if noise.get_noise_2d(x, y) > cave_threshold:
				tile_map.set_cell(foreground, Vector2i(x, y), 0, dirt)

func generate_noise():
	noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = frequency
	noise.seed = noise_seed
