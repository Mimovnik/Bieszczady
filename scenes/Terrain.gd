extends Node2D

@onready var tile_map = $TileMap

var background = 0
var foreground = 1

const no_tile = Vector2i(-1, -1)
var grass_dirt = Vector2i(0, 0)
var dirt = Vector2i(0, 1)
var stone = Vector2i(6, 1)

@export
var max_width: int = 100

@export
var max_height: int = 100

var noise: FastNoiseLite = null

@export
var frequency: float

@export
var noise_seed: int

@export
var cave_threshold: float

@export
var dirt_layer: float

@export
var steepness: float

@export
var minimum_height: float

func _ready():
	generate_terrain()

func generate_terrain():
	generate_noise()

	for y in range(max_height):
		for x in range(max_width):
			var tile = choose_tile(x, y)
			if tile == no_tile:
				continue
			create_tile(Vector2i(x, y), tile)

func choose_tile(x: int, y: int) -> Vector2i:
	var height: int = noise.get_noise_1d(x) * steepness + minimum_height
	# Create caves
	if noise.get_noise_2d(x,y) < cave_threshold:
		return no_tile
	
	# Create hills
	if y > height:
		return no_tile
	
	if y == height:
		return grass_dirt
		
	if y > height - dirt_layer:
		return dirt
		
	return stone

func create_tile(coords: Vector2i, atlas_coords: Vector2i):
	var y_inverted_coords = Vector2i(coords.x, -coords.y)
	tile_map.set_cell(foreground, y_inverted_coords, 0, atlas_coords)

func generate_noise():
	noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = frequency
	noise.seed = noise_seed
