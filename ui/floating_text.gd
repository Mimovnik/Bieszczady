extends Node2D

@onready var label: Label = $Label
@onready var timer: Timer = $Timer

var text: String

const SPEED: float = 10.0

func _ready():
	label.text = text
	label.show()
	
func _process(delta: float) -> void:
	label.position += Vector2(SPEED * delta, -SPEED * delta)

func _on_timer_timeout() -> void:
	queue_free()
