
extends Area2D

var entered = false

@export_file("*.tscn") var target_room: String

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		entered = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		entered = false

func _process(_delta: float) -> void:
	if entered and Input.is_action_just_pressed("ui_accept"):
		get_tree().change_scene_to_file(target_room)
