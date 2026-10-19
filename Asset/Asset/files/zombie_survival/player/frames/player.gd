extends CharacterBody2D
const speed = 300

func _physics_process(delta):
	var direction = Vector2(Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"), Input.get_action_strength("ui_down")  - Input.get_action_strength("ui_up") )
	print(direction)
