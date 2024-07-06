extends CharacterBody2D

@onready var terrain = %Terrain

@onready var sprite = $AnimatedSprite2D
@onready var camera = $Camera2D

const zoom_speed = 1.4
const max_zoom = 5
const SPEED = 300.0

func _ready():
	position.x = (terrain.world_width / 2 + 0.5) * terrain.tile_size.x 
	position.y = (terrain.get_height(terrain.world_width / 2) - 1) * terrain.tile_size.y

func _physics_process(_delta):
	move(_delta)
	zoom()
	
func zoom():
	if Input.is_action_just_released("zoom-out"):
		$Camera2D.zoom /= zoom_speed
	if Input.is_action_just_released("zoom-in"):
		$Camera2D.zoom *= zoom_speed
		$Camera2D.zoom.x = min($Camera2D.zoom.x, max_zoom)
		$Camera2D.zoom.y = min($Camera2D.zoom.y, max_zoom)

func move(_delta):
	var horizontal = Input.get_axis("left", "right")
	if horizontal:
		velocity.x = horizontal * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	var vertical = Input.get_axis("up", "down")
	if vertical:
		velocity.y = vertical * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)

	if velocity.x > 0:
		sprite.flip_h = false
	elif velocity.x < 0:
		sprite.flip_h = true

	move_and_slide()
