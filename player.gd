extends CharacterBody2D


# =========================
# MOVEMENT
# =========================

var normal_speed := 100.0
var sprint_speed := 200.0
var minimum_sprint_speed := 50.0


# =========================
# STAMINA
# =========================

var max_stamina := 200.0
var stamina := 200.0

@export var stamina_drain_rate := 15.0
@export var stamina_normal_drain_rate := 5.0
@export var stamina_recovery_rate := 20.0


# =========================
# HEALTH
# =========================

@export var max_health := 100

var health: int
var is_dead := false


# =========================
# SHOOTING
# =========================

@export var bullet_scene: PackedScene
@export var fire_rate := 0.15

@onready var gun_point: Marker2D = $"gun point"

var shoot_cooldown := 0.0
var is_shooting := false


# =========================
# DODGE
# =========================

var dodge_cost := 25.0
var dodge_speed := 800.0
var dodge_duration := 0.15

var is_dodging := false
var dodge_timer := 0.0
var dodge_direction := Vector2.ZERO


# =========================
# REFERENCES
# =========================

@onready var animated_sprite: AnimatedSprite2D = $Visual
@onready var stamina_label: Label = $Player_Stamina
@onready var speed_label: Label = $Player_Speed
@onready var health_label: Label = $"Player Health"


# =========================
# PLAYER DIRECTION
# =========================

var facing_direction := "left"


# =========================
# READY
# =========================

func _ready() -> void:
	health = max_health
	update_health_label()
	print("Player health: ", health)


# =========================
# PHYSICS PROCESS
# =========================

func _physics_process(delta: float) -> void:
	var direction := Vector2.ZERO

	# Movement input
	if Input.is_action_pressed("move_up"):
		direction.y -= 1

	if Input.is_action_pressed("move_down"):
		direction.y += 1

	if Input.is_action_pressed("move_left"):
		direction.x -= 1

	if Input.is_action_pressed("move_right"):
		direction.x += 1

	direction = direction.normalized()

	# Dodge input
	if Input.is_action_just_pressed("dodge") and not is_dodging:
		if stamina >= dodge_cost:
			stamina -= dodge_cost
			is_dodging = true
			dodge_timer = dodge_duration

			if direction != Vector2.ZERO:
				dodge_direction = direction
			else:
				match facing_direction:
					"left":
						dodge_direction = Vector2.LEFT
					"right":
						dodge_direction = Vector2.RIGHT
					"up":
						dodge_direction = Vector2.UP
					"down":
						dodge_direction = Vector2.DOWN

	# Dodge movement
	if is_dodging:
		dodge_timer -= delta
		velocity = dodge_direction * dodge_speed
		move_and_slide()

		if dodge_timer <= 0:
			is_dodging = false

		return

	# Speed
	var current_speed := normal_speed

	if Input.is_key_pressed(KEY_SHIFT) and direction != Vector2.ZERO:
		stamina -= stamina_drain_rate * delta
		var stamina_ratio := stamina / max_stamina

		current_speed = minimum_sprint_speed + (
			sprint_speed - minimum_sprint_speed
		) * stamina_ratio

	elif direction != Vector2.ZERO:
		stamina -= stamina_normal_drain_rate * delta
		current_speed = normal_speed

	else:
		stamina += stamina_recovery_rate * delta
		current_speed = normal_speed

	# Clamp stamina
	stamina = clamp(stamina, 0.0, max_stamina)

	# Debug display
	stamina_label.text = "Stamina: " + str(round(stamina))
	speed_label.text = "Speed: " + str(round(current_speed))
	update_health_label()

	# Movement
	velocity = direction * current_speed
	move_and_slide()

	# Animation
	update_animation(direction)


# =========================
# ANIMATION
# =========================

func update_animation(direction: Vector2) -> void:
	if is_shooting:
		return

	if direction == Vector2.ZERO:
		animated_sprite.play("idle_" + facing_direction)
		return

	if direction.x < 0:
		facing_direction = "left"
		animated_sprite.play("walk_left")

	elif direction.x > 0:
		facing_direction = "right"
		animated_sprite.play("walk_right")

	elif direction.y < 0:
		facing_direction = "up"
		animated_sprite.play("walk_up")

	elif direction.y > 0:
		facing_direction = "down"
		animated_sprite.play("walk_down")


# =========================
# SHOOTING
# =========================

func shoot() -> void:
	if bullet_scene == null:
		print("ERROR: Bullet scene is not assigned!")
		return

	var direction := (
		get_global_mouse_position() - gun_point.global_position
	).normalized()

	if abs(direction.x) > abs(direction.y):
		if direction.x < 0:
			facing_direction = "left"
		else:
			facing_direction = "right"
	else:
		if direction.y < 0:
			facing_direction = "up"
		else:
			facing_direction = "down"

	animated_sprite.play("shoot_" + facing_direction)
	is_shooting = true

	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)

	bullet.global_position = gun_point.global_position
	bullet.direction = direction
	bullet.rotation = direction.angle()


# =========================
# MAIN PROCESS
# =========================

func _process(delta: float) -> void:
	if is_dead:
		return

	update_mouse_direction()

	shoot_cooldown = max(shoot_cooldown - delta, 0.0)

	if Input.is_action_pressed("action"):
		if shoot_cooldown <= 0.0:
			shoot()
			shoot_cooldown = fire_rate
	else:
		is_shooting = false


# =========================
# UPDATE MOUSE DIRECTION
# =========================

func update_mouse_direction() -> void:
	var direction := (
		get_global_mouse_position() - global_position
	).normalized()

	if abs(direction.x) > abs(direction.y):
		if direction.x < 0:
			facing_direction = "left"
		else:
			facing_direction = "right"
	else:
		if direction.y < 0:
			facing_direction = "up"
		else:
			facing_direction = "down"


# =========================
# HEALTH DISPLAY
# =========================

func update_health_label() -> void:
	health_label.text = "Health: " + str(health)


# =========================
# TAKE DAMAGE
# =========================

func take_damage(damage: int) -> void:
	if is_dead:
		return

	health = max(health - damage, 0)
	update_health_label()

	print("Player health: ", health)

	if health <= 0:
		die()


# =========================
# HEAL PLAYER
# =========================

func heal(amount: int) -> void:
	if is_dead:
		return

	health = clampi(health + amount, 0, max_health)
	update_health_label()

	print("Player healed. Current health: ", health)


# =========================
# PLAYER DEATH
# =========================

func die() -> void:
	if is_dead:
		return

	is_dead = true
	velocity = Vector2.ZERO
	is_shooting = false
	is_dodging = false

	set_physics_process(false)
	set_process(false)

	var collision_shape = get_node_or_null("CollisionShape2D")

	if collision_shape:
		collision_shape.set_deferred("disabled", true)

	animated_sprite.play("die")
	print("PLAYER DIED!")

	var frames = animated_sprite.sprite_frames
	var frame_count = frames.get_frame_count("die")
	var fps = frames.get_animation_speed("die")

	if fps > 0:
		await get_tree().create_timer(
			float(frame_count) / fps
		).timeout

	print("Player death animation finished")
