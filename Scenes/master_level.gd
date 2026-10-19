extends Node2D

@onready var player = $player
@onready var world = $World

var current_room: Node2D


func _ready() -> void:
	current_room = world.get_child(1)


func change_room(room_path: String, spawn_name: String) -> void:
	var new_room = load(room_path).instantiate()
	world.add_child(new_room)

	var spawn = new_room.find_child(spawn_name, true, false) as Marker2D

	if spawn == null:
		push_error("Spawn marker not found: " + spawn_name)
		new_room.queue_free()
		return

	current_room.queue_free()
	current_room = new_room

	player.global_position = spawn.global_position
