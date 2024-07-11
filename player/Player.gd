extends CharacterBody2D

@onready var terrain = %Terrain

@onready var sprite = $AnimatedSprite2D
@onready var camera = $Camera2D
@onready var gather_cooldown: Timer = $GatherCooldown

@export var speed = 100.0
@export var jump_velocity = -400.0

@export var jump_coyote_frames = 10
@export var step_help_frames = 4
@export var jump_help_free_frames = 10

const zoom_speed = 1.4
const max_zoom = 5

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var last_floor_frames: int = 0
var touch_wall_frames: int = 0
var after_jump_frames: int = 0

var gather_on_cooldown: bool = false

func _ready():
	position.x = (terrain.world_width / 2 + 0.5) * terrain.block_map.tile_set.tile_size.x 
	position.y = (terrain.get_height(terrain.world_width / 2) - 1) * terrain.block_map.tile_set.tile_size.y
	gather_cooldown.timeout.connect(func():
			gather_on_cooldown = false; gather_cooldown.stop())

func _physics_process(_delta):
	move(_delta)
	gather()
	zoom()
	
	# Flip sprite
	if velocity.x > 0:
		sprite.flip_h = false
	elif velocity.x < 0:
		sprite.flip_h = true
	
func zoom():
	if Input.is_action_just_released("zoom-out"):
		$Camera2D.zoom /= zoom_speed
	if Input.is_action_just_released("zoom-in"):
		$Camera2D.zoom *= zoom_speed
		$Camera2D.zoom.x = min($Camera2D.zoom.x, max_zoom)
		$Camera2D.zoom.y = min($Camera2D.zoom.y, max_zoom)

func move(_delta):
	count_special_frames()
	
	add_gravity(_delta)

	var horizontal = Input.get_axis("left", "right")
	
	horizontal_move(horizontal)
	
	step_help(horizontal)
	
	handle_jump()
	
	move_and_slide()
	
func gather():
	if gather_on_cooldown:
		return
	if Input.is_action_pressed("left_click"):
		gather_cooldown.start()
		gather_on_cooldown = true
		var damage = 1
		var mouse_pos: Vector2 = get_global_mouse_position()
		terrain.dig_block_at(mouse_pos, damage)

func count_special_frames():
	if is_on_wall():
		touch_wall_frames += 1
	else:
		touch_wall_frames = 0
	
	if is_on_floor():
		last_floor_frames = 0
	else:
		last_floor_frames += 1
	
	after_jump_frames += 1
	
func add_gravity(_delta):
	if not is_on_floor():
		velocity.y += gravity * _delta

func horizontal_move(horizontal):
	if horizontal:
		velocity.x = horizontal * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	
func step_help(horizontal):
	if is_on_wall() and horizontal and touch_wall_frames < step_help_frames and after_jump_frames > jump_help_free_frames:
		velocity.y = -speed
		
func handle_jump():
	if Input.is_action_just_pressed("jump") and (last_floor_frames < jump_coyote_frames or is_on_wall()):
		velocity.y = jump_velocity
		after_jump_frames = 0
