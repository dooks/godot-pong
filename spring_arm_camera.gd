extends SpringArm3D

@export var stiffness := 20.0
@export var damping := 5.0
@export var zoom_speed := 3.0
@export var max_zoom := 10.0
@export var min_zoom := 2.0
@export_range(0.0, 45.0, 0.5, "degrees") var tilt_at_min_zoom := 15.0

@onready var target: Node3D = $"../Player1/Paddle"

var vel := 0.0
var _base_tilt: float

func _ready() -> void:
	_base_tilt = rotation.x

func _physics_process(delta: float) -> void:
	var acc := stiffness * (target.global_position.x - global_position.x) - damping * vel
	vel += acc * delta
	global_position.x += vel * delta

	if Input.is_key_pressed(KEY_DOWN):
		spring_length = min(spring_length + zoom_speed * delta, max_zoom)
	if Input.is_key_pressed(KEY_UP):
		spring_length = max(spring_length - zoom_speed * delta, min_zoom)

	var t := inverse_lerp(min_zoom, max_zoom, spring_length)
	rotation.x = lerp(_base_tilt + deg_to_rad(tilt_at_min_zoom), _base_tilt, t)
