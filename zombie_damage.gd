extends Label

var rise_speed := 40.0
var lifetime := 0.7
var elapsed := 0.0


func setup(damage: int):
	text = "-" + str(damage)


func _process(delta):
	elapsed += delta

	position.y -= rise_speed * delta

	modulate.a = 1.0 - (elapsed / lifetime)

	if elapsed >= lifetime:
		queue_free()
