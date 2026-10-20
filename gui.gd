
extends CanvasLayer

@onready var health_label: Label = $Health
@onready var stamina_label: Label = $Stamina

var player: Node2D = null


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player") as Node2D


func _process(_delta: float) -> void:
	# Find the player if it wasn't available at startup.
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as Node2D

	if player == null:
		return

	# Read health values from the player.
	var health = player.get("health")
	var max_health = player.get("max_health")

	if health != null and max_health != null:
		health_label.text = "Health: %s / %s" % [
			str(health), str(max_health)
		]

	# Read stamina values from the player.
	var stamina = player.get("stamina")
	var max_stamina = player.get("max_stamina")

	if stamina != null and max_stamina != null:
		stamina_label.text = "Stamina: %d / %d" % [
			int(stamina), int(max_stamina)
		]
