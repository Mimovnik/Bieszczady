class_name BlockMap extends TileMap

const ATLAS_SOURCE: int = 0

var blocks: Dictionary = {}

var block_prefab_by_name: Dictionary = {}

func _ready() -> void:
	_map_block_prefabs()

func get_block_prefab(name: String) -> BlockPrefab:
	return block_prefab_by_name[name]

func get_block(coords: Vector2i) -> Block:
	if !blocks.has(coords):
		return null
	return blocks[coords]
	
func create_block(coords: Vector2i, block_prefab: BlockPrefab, layer: int):
	var block = block_prefab.scene.instantiate()
	assert(!blocks.has(coords), "There already is a block at " + str(coords))
	
	block.coords = coords
	block.layer = layer
	block.prefab = block_prefab
	
	add_child(block)
	set_cell(layer, coords, ATLAS_SOURCE, block_prefab.atlas_coords)
	blocks[coords] = block
	block.durability_depleted.connect(_on_block_durability_depleted)

func remove_block(coords: Vector2i, layer: int):
	erase_cell(layer, coords)
	var block = blocks[coords]
	blocks.erase(coords)
	block.queue_free()

func _on_block_durability_depleted(block: Block):
	remove_block(block.coords, block.layer)

func _map_block_prefabs():
	var atlas = tile_set.get_source(ATLAS_SOURCE)
	var size = atlas.get_atlas_grid_size()
	
	for x in size.x:
		for y in size.y:
			var coords = atlas.get_tile_at_coords(Vector2i(x, y))
			if coords == Vector2i(-1, -1): # not a tile
				continue
				
			var tile_data = atlas.get_tile_data(coords, 0)
			
			var block_name: String = tile_data.get_custom_data("block_name")
			
			# Skip unnamed tiles
			if block_name == null or block_name.is_empty():
				continue
			
			var block_scene: PackedScene = tile_data.get_custom_data("block_scene")
			assert(block_scene != null, "Tile at " + str(coords) + " doesn't have block_scene")
			
			block_prefab_by_name[block_name] = BlockPrefab.new(block_scene, coords)
