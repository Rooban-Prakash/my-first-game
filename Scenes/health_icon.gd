extends Area2D

@export var heal_amount: int = 20

var collected: bool = false

func _on_body_entered(body: Node2D) -> void:
	if collected:
		return

	if body.is_in_group("player") and body.has_method("heal"):
		print("Current player health: ", body.health)

		if body.health < body.max_health:
			collected = true
			body.heal(heal_amount)

			print("Health icon collected!")
			print("Health after healing: ", body.health)
			queue_free()
		else:
			print("Health is already full")
