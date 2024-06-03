extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D

const SPEED = 300.0

func _physics_process(_delta):
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
