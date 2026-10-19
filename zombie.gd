
extends CharacterBody2D

@export var min_speed := 70.0
@export var max_speed := 100.0
@export var stop_distance := 35.0
@export var max_health := 100

var speed: float
var health: int
var is_dead := false
var has_detected_player := false

@export var attack_damage := 10
@export var attack_interval := 1.0

var attack_timer := 0.0
var player: Node2D = null

var damage_number_scene = preload("res://zombie_damage.tscn")

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $"Detection Area"
@onready var attack_area: Area2D = $"Atack Area"
@onready var damage_label: Label = get_node_or_null("Damage label")
@onready var health_label: Label = get_node_or_null("Health_label")


func _ready() -> void:
	health = max_health
	speed = randf_range(min_speed, max_speed)
	player = get_tree().get_first_node_in_group("player")

	if health_label != null:
		health_label.show()
		health_label.text = "Health: %d / %d" % [health, max_health]
	else:
		push_error("Health_label was not found!")

	update_health_label()


func _physics_process(delta: float) -> void:
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
		if player == null:
			return
	
	if not player.is_in_group("player"):
		player = get_tree().get_first_node_in_group("player")
		return

	if player.is_dead or is_dead:
		velocity = Vector2.ZERO
		return

	if health_label != null:
		health_label.show()
		health_label.modulate = Color.WHITE

	attack_timer = maxf(attack_timer - delta, 0.0)

	var in_attack: bool = attack_area.overlaps_body(player)
	var in_detect: bool = detection_area.overlaps_body(player)

	if in_detect or in_attack:
		has_detected_player = true

	if has_detected_player:
		var distance: float = global_position.distance_to(player.global_position)

		if distance > stop_distance:
			velocity = global_position.direction_to(player.global_position) * speed
		else:
			velocity = Vector2.ZERO

		animated_sprite.flip_h = player.global_position.x < global_position.x

		if in_attack:
			_play_anim("zombie_attack")
			attack_player()
		else:
			_play_anim("zombie_idle")
	else:
		velocity = Vector2.ZERO
		_play_anim("zombie_idle")

	move_and_slide()


func _play_anim(anim_name: String) -> void:
	if animated_sprite.animation != anim_name:
		animated_sprite.play(anim_name)


func attack_player() -> void:
	if is_dead or attack_timer > 0.0:
		return

	attack_timer = attack_interval

	if player != null and is_instance_valid(player) and player.has_method("take_damage"):
		player.take_damage(attack_damage)


func update_health_label() -> void:
	if health_label != null:
		health_label.text = "Health: %d / %d" % [health, max_health]


func take_damage(damage: int) -> void:
	if is_dead:
		return

	health = maxi(health - damage, 0)
	update_health_label()

	var indicator = damage_number_scene.instantiate()
	get_tree().current_scene.add_child(indicator)
	indicator.setup(damage)
	indicator.global_position = global_position + Vector2(0, -30)

	if health <= 0:
		die()


func die() -> void:
	if is_dead:
		return

	is_dead = true
	velocity = Vector2.ZERO

	# Stop movement and damage immediately.
	set_physics_process(false)

	# Disable the zombie's physical collision.
	var collision_shape = get_node_or_null("CollisionShape2D")
	if collision_shape:
		collision_shape.set_deferred("disabled", true)

	# Disable detection and attack areas.
	detection_area.set_deferred("monitoring", false)
	detection_area.set_deferred("monitorable", false)
	attack_area.set_deferred("monitoring", false)
	attack_area.set_deferred("monitorable", false)

	# Play the death animation.
	animated_sprite.play("zombie_death")

	# Wait for the animation to finish.
	var frames = animated_sprite.sprite_frames
	var frame_count = frames.get_frame_count("zombie_death")
	var fps = frames.get_animation_speed("zombie_death")

	if fps > 0:
		await get_tree().create_timer(float(frame_count) / fps).timeout

	queue_free()
