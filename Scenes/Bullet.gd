extends Area2D

@export var speed := 500.0
@export var damage := 7

var direction := Vector2.ZERO

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	# Ignore the player
	if body.name == "player":
		return

	#print("HIT OBJECT: ", body.name)

	if body.has_method("take_damage"):
		body.take_damage(damage)

	queue_free()
