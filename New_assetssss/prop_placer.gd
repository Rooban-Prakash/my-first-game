extends Node2D
## Spawns your decoration/prop sprites at grid-aligned positions.
##
## WHY THIS ISN'T PART OF THE TILEMAP:
## Your ground tiles (grass, dirt, asphalt, etc.) are all a uniform
## 64x64 and tile edge-to-edge, so they belong in a TileMapLayer.
## Your props (bins, trees, fences, dustbins, crates, doors...) are
## NOT uniform — they range from 64x120 up to 120x128, because they're
## drawn as "standing" objects taller than one grid cell (the extra
## height is the object rising above its footprint, same convention
## as trees/houses in games like Stardew Valley). Godot's TileMap
## expects one consistent region size per grid it paints, so forcing
## these into the ground grid would either crop them or misalign the
## grid. The standard fix — and what this script does — is: keep
## props as ordinary nodes, but still snap their *placement* to the
## same 64px grid as the ground so everything lines up visually.
##
## Attach this to the "Props" Node2D in world_level.tscn.

const GRID = 64

## asset: texture path (relative to res://assets/tiles/props/<category>/)
## col,row: grid position (same grid as your ground TileMapLayer)
## solid: true = add a StaticBody2D so zombies/player collide with it
const PROP_DATA = [
	# --- props_street_sheet (backgrounds: benches, bins, fences, etc.) ---
	{"path":"street/bench.png",        "col":4,  "row":3,  "solid":true},
	{"path":"street/lamp_post.png",    "col":2,  "row":2,  "solid":true},
	{"path":"street/traffic_cone.png", "col":6,  "row":5,  "solid":false},
	{"path":"street/bin_blue.png",     "col":3,  "row":6,  "solid":true},
	{"path":"street/bin_green.png",    "col":4,  "row":6,  "solid":true},
	{"path":"street/barrel_rust.png",  "col":9,  "row":4,  "solid":true},
	{"path":"street/crate_wood.png",   "col":8,  "row":6,  "solid":true},
	{"path":"street/fence.png",        "col":1,  "row":5,  "solid":true},
	{"path":"street/fence_post.png",   "col":1,  "row":6,  "solid":true},
	{"path":"street/cardboard_box.png","col":7,  "row":7,  "solid":false},

	# --- props_nature_sheet ---
	{"path":"nature/tree.png",         "col":0,  "row":0,  "solid":true},
	{"path":"nature/dead_tree.png",    "col":10, "row":1,  "solid":true},
	{"path":"nature/bush_a.png",       "col":2,  "row":4,  "solid":false},
	{"path":"nature/bush_b.png",       "col":8,  "row":3,  "solid":false},
	{"path":"nature/rocks.png",        "col":5,  "row":7,  "solid":true},
	{"path":"nature/rocks_small.png",  "col":6,  "row":7,  "solid":false},
	{"path":"nature/tires.png",        "col":9,  "row":7,  "solid":false},
	{"path":"nature/barrel_red.png",   "col":10, "row":4,  "solid":true},
	{"path":"nature/hole.png",         "col":3,  "row":8,  "solid":false},
	{"path":"nature/crate_small.png",  "col":7,  "row":6,  "solid":true},

	# --- doors_crates_sheet ---
	{"path":"doors/door_closed.png",     "col":5, "row":3, "solid":true},
	{"path":"doors/door_open.png",       "col":6, "row":3, "solid":false},
	{"path":"doors/crate_breakable.png", "col":5, "row":5, "solid":true},
	{"path":"doors/crate_broken.png",    "col":6, "row":5, "solid":false},

	# --- dustbin_hide_sheet (your hide-from-zombies spots) ---
	{"path":"dustbin/closed.png",       "col":11, "row":5, "solid":true},
	{"path":"dustbin/closed_alt.png",   "col":11, "row":6, "solid":true},
	{"path":"dustbin/open.png",         "col":12, "row":5, "solid":true},
	{"path":"dustbin/player_hidden.png","col":12, "row":6, "solid":true},
]

@export var props_root_path: String = "res://assets/tiles/props/"

func _ready():
	for entry in PROP_DATA:
		spawn_prop(entry)

func spawn_prop(entry: Dictionary):
	var tex := load(props_root_path + entry["path"]) as Texture2D
	if tex == null:
		push_warning("Missing prop texture: " + entry["path"])
		return

	var pos := Vector2(entry["col"] * GRID + GRID/2.0, entry["row"] * GRID + GRID)
	# anchor at the BOTTOM of the cell (pos.y = bottom edge), since these
	# sprites are taller than one tile and should look like they're
	# "standing" on their footprint cell, not centered inside it.

	var sprite := Sprite2D.new()
	sprite.texture = tex
	sprite.centered = true

	if entry.get("solid", false):
		var body := StaticBody2D.new()
		body.position = pos
		sprite.position = Vector2(0, -tex.get_height()/2.0)  # local offset so sprite bottom sits on pos
		var shape := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = Vector2(GRID*0.8, GRID*0.6)  # rough footprint, not full sprite bounds
		shape.shape = rect
		shape.position = Vector2(0, -GRID*0.3)
		body.add_child(shape)
		body.add_child(sprite)
		add_child(body)
	else:
		sprite.position = pos + Vector2(0, -tex.get_height()/2.0)
		add_child(sprite)
