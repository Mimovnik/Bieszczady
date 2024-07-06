extends Node2D

@onready var tile_map = $TileMap

@onready var tile_size = $TileMap.tile_set.tile_size

var background = 0
var midground = 1

var cheese_cave_noise: FastNoiseLite = null
var noodle_cave_noise: FastNoiseLite = null
var height_noise: FastNoiseLite = null

@export var world_seed: int

@export var world_width: int = 100
@export var world_height: int = 100

@export var cheese_cave_freq: float
@export var cheese_cave_threshold: float

@export var noodle_cave_freq: float
@export var noodle_cave_threshold: float

@export var height_freq: float
@export var height_threshold: float
@export var steepness: float
@export var minimum_height: float

@export var top_layer: float

const no_tile = Vector2i(-1, -1)
var name_to_coords = {}

func _ready():
	map_block_names_to_coords()
	generate_terrain()
	
func map_block_names_to_coords():
	var atlas =  $TileMap.tile_set.get_source(0)
	var size = atlas.get_atlas_grid_size()
	for x in size.x:
		for y in size.y:
			var coords = atlas.get_tile_at_coords(Vector2i(x, y))
			if coords == no_tile:
				continue
			var tile_data = atlas.get_tile_data(coords, 0)
			if tile_data == null:
				continue
			var block_name: String = tile_data.get_custom_data("name")
			if block_name == null or block_name.is_empty():
				continue
			name_to_coords[block_name] = Vector2i(x, y)
	
func get_height(x: int):
	var height_at_x: int = 0
	for y in range(0, -world_height, -1): # in godot y decreases upwards
		# if tile exists
		if tile_map.get_cell_source_id(midground, Vector2i(x, y)) != -1:
			height_at_x = y
	return height_at_x

func generate_terrain():
	generate_noise()

	for y in range(world_height):
		for x in range(world_width):
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
		return name_to_coords["grass_dirt"]
		
	if y > height - top_layer:
		return name_to_coords["dirt"]
		
	return name_to_coords["stone"]
	
func create_tile(coords: Vector2i, atlas_coords: Vector2i):
	var y_inverted_coords = Vector2i(coords.x, -coords.y) # in godot y decreases upwards
	tile_map.set_cell(midground, y_inverted_coords, 0, atlas_coords)

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
