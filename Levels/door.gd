extends Area2D

@export var target_room: PackedScene

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	if target_room == null:
		push_error("No target room assigned!")
		return

	get_tree().change_scene_to_packed(target_room)
