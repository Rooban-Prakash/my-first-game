extends Node2D

# Playable prototype built around the supplied cave tileset artwork.
# WASD = move. Arrow keys also work.

var player := Vector2(480, 430)
var speed := 220.0
var camera := Vector2.ZERO

# The supplied artwork is used as the cave layout texture.
var cave_texture: Texture2D

func _ready():
	cave_texture = load("res://cave_tileset.png")
	queue_redraw()

func _process(delta):
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction.length() > 0.0:
		player += direction.normalized() * speed * delta
		player.x = clamp(player.x, 30.0, 930.0)
		player.y = clamp(player.y, 30.0, 610.0)
	queue_redraw()

func _draw():
	# Dark cave background.
	draw_rect(Rect2(0, 0, 960, 640), Color("#090909"))

	# Scale the supplied cave artwork to form the playable level.
	if cave_texture:
		var src_size := cave_texture.get_size()
		var target := Rect2(0, 0, 960, 640)
		draw_texture_rect(cave_texture, target, false)

	# Subtle playable-area vignette.
	draw_rect(Rect2(0, 0, 960, 640), Color(0, 0, 0, 0.12), false, 2.0)

	# Player marker.
	draw_circle(player, 13.0, Color("#f4f0d0"))
	draw_circle(player, 9.0, Color("#c85b36"))
	draw_circle(player, 3.0, Color("#fff5cf"))

	# Direction marker.
	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if dir.length() == 0:
		dir = Vector2.DOWN
	draw_line(player, player + dir.normalized() * 22.0, Color("#fff5cf"), 3.0)

	# Small HUD.
	draw_rect(Rect2(16, 16, 230, 42), Color(0, 0, 0, 0.72))
	draw_string(ThemeDB.fallback_font, Vector2(28, 43), "WASD / ARROWS  •  MOVE", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#eeeeee"))
