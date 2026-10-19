
extends Node2D

@export var starting_room: PackedScene

@onready var player: CharacterBody2D = $World/player
@onready var world: Node2D = $World

var current_room: Node2D

func _ready() -> void:
	change_room(starting_room, "SouthSpawn")


func change_room(
	room_scene: PackedScene,
	spawn_name: String
) -> void:
	if room_scene == null:
		return

	var new_room = room_scene.instantiate()
	world.add_child(new_room)

	var spawn = new_room.find_child(spawn_name, true, false) as Marker2D

	if spawn == null:
		push_error("Spawn marker not found: " + spawn_name)
		new_room.queue_free()
		return

	player.global_position = spawn.global_position

	if current_room != null:
		current_room.queue_free()

	current_room = new_room
