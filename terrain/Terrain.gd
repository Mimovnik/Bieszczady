extends Node2D

const FloatingText = preload("res://ui/floating_text.tscn")
const Block = preload("res://terrain/Block.gd")

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
class BlockData:
	var display_name: String
	var durability: int
	var atlas_coords: Vector2i
	
	func _init(display_name: String, durability: int, atlas_coords: Vector2i):
		self.display_name = display_name
		self.durability = durability
		self.atlas_coords = atlas_coords

var name_to_block_data = {}

var blocks = {}

func _ready():
	generate_terrain()

func dig_block_at(position: Vector2, damage: int):
	var coords: Vector2i = tile_map.local_to_map(position)
	var block: Block = get_block_at(coords)
	if block == null:
		return
	block.hit(damage)
	spawn_text(str(block.durability), position)
	

func spawn_text(text: String, position: Vector2):
	var instance = FloatingText.instantiate()
	instance.position = position
	instance.text = text
	add_child(instance)

func get_block_at(coords: Vector2i) -> Block:
	if !blocks.has(coords):
		return null
	return blocks[coords]
	
func map_names_to_block_data():
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
				
			var display_name: String = tile_data.get_custom_data("name")
			if display_name == null or display_name.is_empty():
				continue
		
			var durability: int = tile_data.get_custom_data("durability")
			name_to_block_data[display_name] = BlockData.new(display_name, durability, coords)
	
func get_height(x: int):
	var height_at_x: int = 0
	for y in range(0, -world_height, -1): # in godot y decreases upwards
		# if tile exists
		if tile_map.get_cell_source_id(midground, Vector2i(x, y)) != -1:
			height_at_x = y
	return height_at_x

func generate_terrain():
	generate_noise()

	map_names_to_block_data()
	for y in range(world_height):
		for x in range(world_width):
			var block = choose_block(x, y)
			if block == null:
				continue
			create_tile(Vector2i(x, y), block)

func choose_block(x: int, y: int) -> BlockData:
	# ---Terrain shaping---
	var height: int = height_noise.get_noise_1d(x) * steepness + minimum_height
	
	if y > height:
		return null
		
	# Create caves
	var cave_density = cheese_cave_noise.get_noise_2d(x, y)
	var height_factor = 1 - (float)(y) / height
	if cave_density * height_factor < cheese_cave_threshold:
		return null
		
	if abs(noodle_cave_noise.get_noise_2d(x,y)) < noodle_cave_threshold:
		return null
	
	
	# ---Decorations---
	if y == height:
		return name_to_block_data["grass_dirt"]
		
	if y > height - top_layer:
		return name_to_block_data["dirt"]
		
	return name_to_block_data["stone"]
	
func create_tile(coords: Vector2i, block_data: BlockData):
	var y_inverted_coords = Vector2i(coords.x, -coords.y) # in godot y decreases upwards
	tile_map.set_cell(midground, y_inverted_coords, 0, block_data.atlas_coords)
	var block = Block.new(block_data.display_name, block_data.durability, midground, y_inverted_coords)
	blocks[y_inverted_coords] = block
	block.durability_depleted.connect(_on_block_durability_depleted)
	
func _on_block_durability_depleted(block: Block):
	tile_map.erase_cell(block.layer, block.coords)
	var was_there = blocks.erase(block.coords)
	assert(was_there, "Erasing block that wasn't in 'terrain.blocks'")
	block.queue_free()

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
