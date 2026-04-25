@tool
extends RigidBody3D

@export var player: Player

var color: Color:
	set(value):
		color = value
		_update_color()

var _target_velocity := 0.0

func _make_mat() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	return mat

func _update_color() -> void:
	var mesh := get_node_or_null("MeshInstance3D") as MeshInstance3D
	if mesh:
		mesh.material_override = _make_mat()

func _ready() -> void:
	if not player:
		player = get_parent() as Player
	if player:
		color = player.color
		player.color_changed.connect(func(c): color = c)
		player.move_changed.connect(func(v): _target_velocity = v)

func _physics_process(_delta: float) -> void:
	linear_velocity = Vector3(_target_velocity, 0, 0)
