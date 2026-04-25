class_name Ball
extends RigidBody3D

@export var initial_speed := 5.0
@export var min_speed := 4.0
@export var max_speed := 15.0
@export var min_bounce_angle := 15.0

func _reset() -> void:
	global_position = Vector3.ZERO
	linear_velocity = Vector3(1, 0, randf_range(-1, 1)).normalized() * initial_speed

func _ready() -> void:
	GameState.ball = self
	_reset()

	var mat := PhysicsMaterial.new()
	mat.friction = 0.0
	mat.bounce = 1.0
	physics_material_override = mat
	gravity_scale = 0.0
	linear_damp_mode = RigidBody3D.DAMP_MODE_REPLACE
	linear_damp = 0.0
	axis_lock_angular_y = false
	contact_monitor = true
	max_contacts_reported = 1
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	linear_velocity = (linear_velocity * 1.05).limit_length(max_speed)

func _physics_process(delta: float) -> void:
	if linear_velocity.length_squared() > 0.01:
		var target_y := atan2(-linear_velocity.x, -linear_velocity.z)
		rotation.y = lerp_angle(rotation.y, target_y, delta * 8)

	if linear_velocity.length_squared() < min_speed * min_speed:
		linear_velocity = linear_velocity.normalized() * min_speed
