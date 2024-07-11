class_name BlockPrefab extends Node

var scene: PackedScene

var atlas_coords: Vector2i

func _init(scene: PackedScene, atlas_coords: Vector2i) -> void:
	self.scene = scene
	self.atlas_coords = atlas_coords
