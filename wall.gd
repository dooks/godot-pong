@tool
extends StaticBody3D

func _update_size() -> void:
	var collision := get_node_or_null("CollisionShape3D") as CollisionShape3D
	if collision and collision.shape is BoxShape3D:
		(collision.shape as BoxShape3D).size = scale

	var mesh := get_node_or_null("MeshInstance3D") as MeshInstance3D
	if mesh and mesh.mesh is BoxMesh:
		(mesh.mesh as BoxMesh).size = scale
