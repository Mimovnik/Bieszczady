extends Node2D

const FloatingText = preload("res://ui/floating_text.tscn")

@onready var block_map: BlockMap = $BlockMap

const BACKGROUND = 0
const MIDGROUND = 1
const FOREGROUND = 2

var rng = RandomNumberGenerator.new()

@export var world_seed: int

@export var world_width: int = 100
@export var world_height: int = 100

var cheese_cave_noise: FastNoiseLite = null
@export var cheese_cave_freq: float
@export var cheese_cave_threshold: float

var noodle_cave_noise: FastNoiseLite = null
@export var noodle_cave_freq: float
@export var noodle_cave_threshold: float

var tree_noise: FastNoiseLite = null
@export var tree_freq: float
@export var tree_threshold: float
@export var tree_min_height: int
@export var tree_max_height: int

var bush_noise: FastNoiseLite = null
@export var bush_freq: float
@export var bush_threshold: float

var height_noise: FastNoiseLite = null
@export var height_freq: float
@export var height_threshold: float
@export var steepness: float
@export var minimum_height: float

@export var top_layer: float

func dig_block_at(position: Vector2, damage: int):
	var coords: Vector2i = block_map.local_to_map(position)
	var block: Block = block_map.get_block(coords)
	if block == null:
		return
	block.hit(damage)
	spawn_text(str(block.durability), position)
	

func spawn_text(text: String, position: Vector2):
	var instance = FloatingText.instantiate()
	instance.position = position
	instance.text = text
	add_child(instance)
	
func get_height(x: int):
	var height_at_x: int = 0
	for y in range(0, -world_height, -1): # in godot y decreases upwards
		if block_map.get_block(Vector2i(x, y)) != null:
			height_at_x = y
	return height_at_x

func _ready():
	_generate_terrain()

func _generate_terrain():
	_generate_noise()

	for y in range(world_height):
		for x in range(world_width):
			_create_block(x, y)
	
func _create_tree(coords: Vector2i, height: int):
	block_map.create_block(coords, block_map.get_block_prefab("tree_trunk"), BACKGROUND)
	
	for y in range(0, height):
		block_map.create_block(Vector2i(coords.x, coords.y - 1 - y), block_map.get_block_prefab("tree_trunk_mid"), BACKGROUND)
	
	block_map.create_block(Vector2i(coords.x, coords.y - 1 - height), block_map.get_block_prefab("tree_leaves"), BACKGROUND)
	
func _create_block(x: int, y: int):
	var coords = Vector2i(x, -y) # in godot y decreases upwards
	# ---Terrain shaping---
	var height: int = height_noise.get_noise_1d(x) * steepness + minimum_height
	
	if y > height:
		return
		
	# Create caves
	var cave_density = cheese_cave_noise.get_noise_2d(x, y)
	var height_factor = 1 - (float)(y) / height
	if cave_density * height_factor < cheese_cave_threshold:
		return
		
	if abs(noodle_cave_noise.get_noise_2d(x, y)) < noodle_cave_threshold:
		return
	
	# ---Decorations---
	if y == height:
		block_map.create_block(coords, block_map.get_block_prefab("grass_dirt"), MIDGROUND)
		
		if tree_noise.get_noise_1d(x) < tree_threshold:
			_create_tree(Vector2i(coords.x, coords.y - 1), rng.randi_range(tree_min_height, tree_max_height))
		elif bush_noise.get_noise_1d(x) < bush_threshold:
			_create_random_bush(Vector2i(coords.x, coords.y - 1))
		return
		
	if y > height - top_layer:
		block_map.create_block(coords, block_map.get_block_prefab("dirt"), MIDGROUND)
		return
		
	block_map.create_block(coords, block_map.get_block_prefab("stone"), MIDGROUND)

func _create_random_bush(coords: Vector2i):
	var rand = rng.randf_range(0, 1)
	if rand < 0.25:
		block_map.create_block(coords, block_map.get_block_prefab("bush_big"), BACKGROUND)
	elif rand < 0.5:
		block_map.create_block(coords, block_map.get_block_prefab("bush_medium"), BACKGROUND)
	elif rand < 0.75:
		block_map.create_block(coords, block_map.get_block_prefab("bush_small"), BACKGROUND)
	else:
		block_map.create_block(coords, block_map.get_block_prefab("bush_flower"), BACKGROUND)
		

func _generate_noise():
	cheese_cave_noise = FastNoiseLite.new()
	cheese_cave_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	cheese_cave_noise.frequency = cheese_cave_freq
	cheese_cave_noise.seed = world_seed
	
	noodle_cave_noise = FastNoiseLite.new()
	noodle_cave_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noodle_cave_noise.frequency = noodle_cave_freq
	noodle_cave_noise.seed = world_seed + 111
	
	height_noise = FastNoiseLite.new()
	height_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	height_noise.frequency = height_freq
	height_noise.seed = world_seed + 222
	
	tree_noise = FastNoiseLite.new()
	tree_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	tree_noise.frequency = tree_freq
	tree_noise.seed = world_seed + 333

	bush_noise = FastNoiseLite.new()
	bush_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	bush_noise.frequency = bush_freq
	bush_noise.seed = world_seed + 444
