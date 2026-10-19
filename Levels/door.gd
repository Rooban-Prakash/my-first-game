
extends Area2D

var entered = false

@export_file("*.tscn") var target_room: String
@export_enum("top_side", "bottom_side", "left_side", "right_side")
var target_spawn: String = "right_side"


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		entered = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		entered = false


func _process(_delta: float) -> void:
	if entered and Input.is_action_just_pressed("ui_action"):
		if target_room.is_empty():
			push_error("Target room is not assigned!")
			return

		get_tree().current_scene.change_room(target_room, target_spawn)
