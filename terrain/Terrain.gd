extends Node2D

const FloatingText = preload("res://ui/floating_text.tscn")

@onready var block_map: BlockMap = $BlockMap

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
			var block_prefab = _choose_block(x, y)
			if block_prefab == null:
				continue
			var coords = Vector2i(x, -y) # -y -> in godot y decreases upwards
			block_map.create_block(coords, block_prefab, midground)

func _choose_block(x: int, y: int) -> BlockPrefab:
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
		return block_map.get_block_prefab("grass_dirt")
		
	if y > height - top_layer:
		return block_map.get_block_prefab("dirt")
		
	return block_map.get_block_prefab("stone")

func _generate_noise():
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
