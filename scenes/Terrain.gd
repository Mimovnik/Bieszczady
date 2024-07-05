extends Node2D

@onready var tile_map = $TileMap

var background = 0
var foreground = 1

const no_tile = Vector2i(-1, -1)
var grass_dirt = Vector2i(0, 0)
var dirt = Vector2i(0, 1)
var stone = Vector2i(6, 1)

var cheese_cave_noise: FastNoiseLite = null
var noodle_cave_noise: FastNoiseLite = null
var height_noise: FastNoiseLite = null

@export var world_seed: int

@export var max_width: int = 100
@export var max_height: int = 100

@export var cheese_cave_freq: float
@export var cheese_cave_threshold: float

@export var noodle_cave_freq: float
@export var noodle_cave_threshold: float

@export var height_freq: float
@export var height_threshold: float
@export var steepness: float
@export var minimum_height: float

@export var top_layer: float

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
	
	# ---Terrain shaping---
	var height: int = height_noise.get_noise_1d(x) * steepness + minimum_height
	
	if y > height:
		return no_tile
		
	# Create caves
	var cave_density = cheese_cave_noise.get_noise_2d(x, y)
	var height_factor = 1 - (float)(y) / height
	if cave_density * height_factor < cheese_cave_threshold:
		return no_tile
		
	if abs(noodle_cave_noise.get_noise_2d(x,y)) < noodle_cave_threshold:
		return no_tile
	
	
	# ---Decorations---
	if y == height:
		return grass_dirt
		
	if y > height - top_layer:
		return dirt
		
	return stone

func create_tile(coords: Vector2i, atlas_coords: Vector2i):
	var y_inverted_coords = Vector2i(coords.x, -coords.y)
	tile_map.set_cell(foreground, y_inverted_coords, 0, atlas_coords)

func generate_noise():
	cheese_cave_noise = FastNoiseLite.new()
	cheese_cave_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	cheese_cave_noise.frequency = cheese_cave_freq
	cheese_cave_noise.seed = world_seed
	
	noodle_cave_noise = FastNoiseLite.new()
	noodle_cave_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noodle_cave_noise.frequency = noodle_cave_freq
	noodle_cave_noise.seed = world_seed
	
	height_noise = FastNoiseLite.new()
	height_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	height_noise.frequency = height_freq
	height_noise.seed = world_seed
