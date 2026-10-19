extends CharacterBody2D


# =========================
# MOVEMENT & HEALTH
# =========================

@export var min_speed := 70.0
@export var max_speed := 100.0
@export var stop_distance := 35.0
@export var max_health := 100

var speed: float
var health: int
var is_dead := false
var has_detected_player := false


# =========================
# ATTACK SETTINGS
# =========================

@export var attack_damage := 10
@export var attack_interval := 1.0

var attack_timer := 0.0


# =========================
# DAMAGE INDICATOR
# =========================

var damage_number_scene = preload("res://zombie_damage.tscn")


# =========================
# REFERENCES
# =========================

@onready var player = get_tree().get_first_node_in_group("player")
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $"Detection Area"
@onready var attack_area: Area2D = $"Atack Area"

# Labels are looked up safely so a wrong name can't crash the game
@onready var damage_label: Label = get_node_or_null("Damage label")
@onready var health_label: Label = get_node_or_null("Health_label")


# =========================
# READY
# =========================

func _ready() -> void:
	health = max_health
	speed = randf_range(min_speed, max_speed)

	#print("Zombie started")
	#print("Health label found: ", health_label != null)

	if health_label != null:
		#print("Label path: ", health_label.get_path())
		#print("Label visible before: ", health_label.visible)
		health_label.show()
		health_label.text = "Health: %d / %d" % [health, max_health]
		#print("Label visible after: ", health_label.visible)
	else:
		push_error("Health_label was not found!")

	update_health_label()

# =========================
# MAIN LOOP
# =========================

func _physics_process(delta: float) -> void:
	if player == null:
		return
	if player.is_dead:
		return
	
	
	if is_dead:
		return
	if health_label != null:
		health_label.show()
		health_label.modulate = Color.WHITE
	# Tick attack cooldown
	attack_timer = maxf(attack_timer - delta, 0.0)

	# Stop everything if the player is dead
	if player.is_dead:
		velocity = Vector2.ZERO
		_play_anim("zombie_idle")
		move_and_slide()
		return

	var in_attack: bool = attack_area.overlaps_body(player)
	var in_detect: bool = detection_area.overlaps_body(player)

	# Remember the player after first detection
	if in_detect or in_attack:
		has_detected_player = true

	if has_detected_player:
		# Keep closing the gap until close enough
		var distance: float = global_position.distance_to(player.global_position)

		if distance > stop_distance:
			velocity = global_position.direction_to(player.global_position) * speed
		else:
			velocity = Vector2.ZERO

		# Face the player
		animated_sprite.flip_h = player.global_position.x < global_position.x

		if in_attack:
			_play_anim("zombie_attack")
			attack_player()
		else:
			# Replace with a walk animation when available
			_play_anim("zombie_idle")
	else:
		velocity = Vector2.ZERO
		_play_anim("zombie_idle")

	move_and_slide()


# =========================
# ANIMATION
# =========================

func _play_anim(anim_name: String) -> void:
	if animated_sprite.animation != anim_name:
		animated_sprite.play(anim_name)


# =========================
# ATTACK PLAYER
# =========================

func attack_player() -> void:
	if attack_timer > 0.0:
		return

	attack_timer = attack_interval

	if player.has_method("take_damage"):
		player.take_damage(attack_damage)


# =========================
# HEALTH DISPLAY
# =========================

func update_health_label() -> void:
	if health_label != null:
		health_label.text = "Health: %d / %d" % [health, max_health]


# =========================
# TAKE DAMAGE
# =========================

func take_damage(damage: int) -> void:
	if is_dead:
		return

	health = maxi(health - damage, 0)
	#print("Zombie health: ", health)

	update_health_label()

	# Spawn floating damage number
	var indicator = damage_number_scene.instantiate()
	get_tree().current_scene.add_child(indicator)

	indicator.setup(damage)
	indicator.global_position = global_position + Vector2(0, -30)

	if health <= 0:
		die()


# =========================
# DEATH
# =========================

func die() -> void:
	if is_dead:
		return

	is_dead = true
	velocity = Vector2.ZERO

	set_physics_process(false)

	var collision_shape = get_node_or_null("CollisionShape2D")
	if collision_shape:
		collision_shape.set_deferred("disabled", true)

	# Stop detection while dying
	detection_area.set_deferred("monitoring", false)
	attack_area.set_deferred("monitoring", false)

	animated_sprite.play("zombie_death")
	print("Death animation started")

	var frames = animated_sprite.sprite_frames
	var frame_count = frames.get_frame_count("zombie_death")
	var fps = frames.get_animation_speed("zombie_death")

	if fps > 0:
		await get_tree().create_timer(float(frame_count) / fps).timeout

	print("Deleting zombie")
	queue_free()
