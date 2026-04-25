@tool
extends Area3D

@export var player: Player

func _update_size() -> void:
	var collision := get_node_or_null("CollisionShape3D") as CollisionShape3D
	if collision and collision.shape is BoxShape3D:
		(collision.shape as BoxShape3D).size = scale

func _on_body_entered(node: Node) -> void:
	if node is Ball:
		GameState.score_goal.emit(player)

func _ready() -> void:
	if not Engine.is_editor_hint():
		assert(player != null, "%s: player must be assigned." % name)

	body_entered.connect(_on_body_entered)
