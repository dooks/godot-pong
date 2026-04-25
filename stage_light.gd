extends SpotLight3D

@export var target: Player

var _paddle: Node3D

func _ready() -> void:
	if target:
		_paddle = target.get_node("Paddle")

func _process(_delta: float) -> void:
	if _paddle:
		look_at(_paddle.global_position)
