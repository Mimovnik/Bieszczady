class_name Block extends Node

@export var display_name: String

@export var durability: int

@export var drop_scene: PackedScene

var coords: Vector2i

var layer: int

var prefab: PackedScene

signal durability_depleted(block: Block)

func hit(damage: int):
	durability -= damage
	if durability <= 0:
		_drop()
		durability_depleted.emit(self)

func _drop():
	if drop_scene == null:
		return

	var drop = drop_scene.instantiate()
	var terrain = get_parent().get_parent()
	
	drop.position = terrain.block_map.map_to_local(coords)
	terrain.add_child(drop)
