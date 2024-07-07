class_name Block extends Node

var display_name: String

var durability: int

var layer: int

var coords: Vector2i

signal durability_depleted(block: Block)

func _init(display_name: String, durability: int, layer: int, coords: Vector2i):
	self.display_name = display_name
	self.durability = durability
	self.layer = layer
	self.coords = coords
	
func hit(damage: int):
	durability -= damage
	if durability <= 0:
		durability_depleted.emit(self)
