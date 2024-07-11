class_name Block extends Node

@export var display_name: String

@export var durability: int

var coords: Vector2i

var layer: int

var prefab: PackedScene

signal durability_depleted(block: Block)

func hit(damage: int):
	durability -= damage
	if durability <= 0:
		durability_depleted.emit(self)
