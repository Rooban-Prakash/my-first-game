
extends Node2D

@onready var player = $player
@onready var world = $World
@onready var kill_label: Label = get_node_or_null("GUI2/Kill Count")

var current_room: Node2D
var killed_zombies: Dictionary = {}
var zombie_kill_count: int = 0


func _ready() -> void:
	if world.get_child_count() > 0:
		current_room = world.get_child(0)

	# Set up the kill counter
	if kill_label != null:
		kill_label.text = "Zombies Killed: 0"
	else:
		push_warning("KillCount label not found. Check CanvasLayer/KillCount.")

	# Debug
	print("=== MASTER DEBUG ===")
	print("Master scene: ", get_tree().current_scene.name)
	print("World path: ", world.get_path())
	print("World children: ", world.get_child_count())

	for child in world.get_children():
		print("World child: ", child.name, " | Path: ", child.get_path())

	if current_room != null:
		print("Current room: ", current_room.name)
	else:
		print("Current room: NONE")

	print("====================")



# Update the kill counter
func register_zombie_kill() -> void:
	zombie_kill_count += 1

	if kill_label != null:
		kill_label.text = "Zombies Killed: " + str(zombie_kill_count)

	print("Zombies killed: ", zombie_kill_count)


# Save the ID of a killed zombie
func register_zombie_killed(room_path: String, zombie_id: String) -> void:
	if not killed_zombies.has(room_path):
		killed_zombies[room_path] = []

	if not killed_zombies[room_path].has(zombie_id):
		killed_zombies[room_path].append(zombie_id)

	print("Saved zombie death: ", zombie_id, " in ", room_path)


# Restore previously killed zombies
func restore_room_state(room: Node2D) -> void:
	var room_path = room.scene_file_path

	print("RESTORE PATH: ", room_path)
	print("SAVED DEATHS: ", killed_zombies.get(room_path, []))

	if not killed_zombies.has(room_path):
		return

	for zombie in room.find_children("*", "CharacterBody2D", true, false):
		var id = zombie.get("zombie_id")

		print("Checking zombie: ", zombie.name, " | ID: ", id)

		if id != null and id != "" and killed_zombies[room_path].has(id):
			print("REMOVING DEAD ZOMBIE: ", zombie.name)
			zombie.queue_free()


# Change rooms
func change_room(room_path: String, spawn_name: String) -> void:
	print("=== ROOM CHANGE START ===")
	print("Requested room: ", room_path)

	if current_room != null:
		print("Current room: ", current_room.name)
	else:
		print("Current room: NONE")

	print("World children before: ", world.get_child_count())

	var packed_room = load(room_path) as PackedScene

	if packed_room == null:
		push_error("Could not load room: " + room_path)
		return

	var new_room = packed_room.instantiate()
	world.add_child(new_room)

	print("New room added: ", new_room.name)

	var spawn = new_room.find_child(spawn_name, true, false) as Marker2D

	if spawn == null:
		push_error("Spawn marker not found: " + spawn_name)
		new_room.queue_free()
		return

	# Restore this room's saved state
	restore_room_state(new_room)

	# Remove the previous room
	if current_room != null:
		print("Removing old room: ", current_room.name)
		current_room.queue_free()
	else:
		print("WARNING: No current room assigned!")

	# Set the new room and move the player
	current_room = new_room
	player.global_position = spawn.global_position

	print("Current room now: ", current_room.name)
	print("=== ROOM CHANGE END ===")
