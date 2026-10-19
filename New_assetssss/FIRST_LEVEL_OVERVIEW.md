# Where things actually are in Asset.zip, and how to build your first level

Your zip has some nested duplicate folders and Godot `.import` cache
files mixed in (normal — that's just Godot's asset cache, ignore any
`.import` file you see). Here's what's actually inside and what to use.

## What's in the zip

| Folder | What it is | Use it? |
|---|---|---|
| `Asset/Asset/files/zombie_survival/environment/frames/environment_tiles_64/` | 16 real 64x64 ground textures (grass, dirt, asphalt, concrete, brick, floor, road line, sewer grate, wood planks) — **same scale as your player/zombie sprites** | ✅ Yes — this is your ground layer |
| `.../environment/frames/props_street_sheet/` | 10 street props (bench, lamp post, bins, barrels, crate, fence, fence post, cardboard box, traffic cone) — 120x128 | ✅ Yes — decoration layer |
| `.../environment/frames/props_nature_sheet/` | 10 nature props (tree, dead tree, bushes, rocks, tires, barrel, hole, small crate) — 88x136 | ✅ Yes — decoration layer |
| `.../environment/frames/doors_crates_sheet/` | 4 pieces (door open/closed, crate breakable/broken) — 64x120 | ✅ Yes — decoration layer |
| `.../environment/frames/dustbin_hide_sheet/` | 4 states of your hide-from-zombies dustbin — 88x136 | ✅ Yes — decoration layer (your gameplay hide mechanic) |
| `Asset/Asset/files/zombie_survival/player/`, `zombie/`, `fx/`, `weapons/` etc. | Your character/animation work from earlier in this conversation | Not part of the tilemap — keep using as before |
| `Asset/post_apoc_world/post_apoc/ground/` | 2 *genuinely seamless* 64x64 wasteland textures (`wasteland_dirt_64.png`, `scorched_ground_64.png`) | ✅ Optional bonus — same scale, already folded into the ground tileset below |
| `Asset/post_apoc_world/post_apoc/buildings/`, `nature/`, `resources/` | Bigger painterly assets (120–312px), reskinned from a different source pack | ❌ Skip for the tilemap — confirmed scale mismatch (a tree here would be 2–5x the size of your ground tiles). Its own README already flags this. Fine as menu/cutscene art later if you want, not for gameplay tiles. |
| `Asset/PALands_DEMO/` | The raw source pack the above was built from | ❌ Not needed directly |
| Various `files.zip`, `zombie_survival.zip`, `post_apoc_world.zip` inside the folders | Duplicate nested copies of the folders above | ❌ Ignore — just extras from how the zip was packed |

## Step 1 — Copy files into your Godot project

Create this structure inside your project (paths matter — they're baked into the `.tres` file below):

```
res://assets/tiles/ground/
    grass_a.png, grass_b.png, dirt.png, concrete_light.png,
    concrete_cracked.png, concrete_gray_spots.png,
    asphalt_cracked_a.png, asphalt_cracked_b.png, asphalt_cracked_c.png,
    asphalt_hole.png, brick_wall.png, floor_tiles_large.png,
    floor_tiles_small.png, road_line.png, sewer_grate.png, wood_planks.png,
    wasteland_dirt_64.png, scorched_ground_64.png

res://assets/tiles/props/street/    <- props_street_sheet files
res://assets/tiles/props/nature/    <- props_nature_sheet files
res://assets/tiles/props/doors/     <- doors_crates_sheet files
res://assets/tiles/props/dustbin/   <- dustbin_hide_sheet files

res://assets/tilesets/ground_tileset.tres   <- provided
res://levels/world_level.tscn               <- provided
res://scripts/prop_placer.gd                <- provided
```

If you'd rather use different folder names, that's fine — just find/replace
the paths inside `ground_tileset.tres` and `prop_placer.gd` to match.

## Step 2 — Open the project and let Godot re-import

The first time you open the project after copying files in, Godot will
regenerate its own `.import` cache and may reassign resource UIDs —
that's normal and expected, not an error. If `ground_tileset.tres`
shows a broken/pink texture on open, double-check the paths above match
exactly (case-sensitive on some systems).

## Step 3 — Build your first level

1. Open `world_level.tscn`. You'll see `World` (root) → `GroundLayer`
   (a `TileMapLayer`, already wired to `ground_tileset.tres`), `Props`
   (empty `Node2D`), `Player` (placeholder with a `Camera2D`).
2. Click `GroundLayer`, open the **TileMap panel** at the bottom of the
   editor. You'll see all 18 ground tiles in the palette.
3. Paint the base terrain — pick `grass_a`/`grass_b` or `dirt` for open
   ground, `asphalt_cracked_*` + `road_line` for streets, `concrete_*`
   for sidewalks/plazas, `brick_wall` for building exteriors,
   `floor_tiles_*` for building interiors. Left-click paints, right-click
   erases, hold shift-drag to rectangle-fill.
4. Use `wasteland_dirt_64` / `scorched_ground_64` for scorched/damaged
   patches — they're a slightly different painting style but same scale,
   so they read fine as "burned ground" variety without clashing.

## Step 4 — Add props (why this is a separate step, not more tile painting)

Your prop sprites aren't uniform tile size (see table above), so they
don't belong in the same paint-a-grid workflow as ground tiles. Two
ways to place them:

**A. By hand (simplest, good for a first level):** drag prop PNGs
straight from the FileSystem dock into the `Props` node in the 2D
viewport, position them by eye, snap to grid with Godot's built-in grid
snapping (⌘/Ctrl+G toggles it). Add a `StaticBody2D` + `CollisionShape2D`
yourself for anything that should block movement (fences, crates,
lamp posts, closed dustbins).

**B. Data-driven (`prop_placer.gd`, provided):** attach it to the
`Props` node instead — it spawns all 28 props from a `col,row` list at
game start, with collision already set up for anything marked
`"solid": true`. Faster for laying out a lot of props consistently, and
it's the same `(col, row)` grid convention as your ground layer, so
things line up. Edit the `PROP_DATA` array to change what's placed
where — it's plain data, safe to hand-edit or generate from a script.

## Step 5 — Wire up the player and camera

`Player` already has a `Camera2D` (zoomed 2x to match your 64px grid at
a reasonable on-screen scale). Swap the placeholder `Player` node for
your actual player scene (the one with the animations from earlier),
or keep this as a stand-in and attach your movement script to it.

## Step 6 — Collision on the ground layer

Only a few ground tiles should ever block movement (`brick_wall` as
building exterior, maybe `asphalt_hole` as a hazard). Rather than
guessing collision shapes for you sight-unseen, set this up in the
TileSet editor: select the tile in the palette → **Physics Layers**
tab → add a layer → paint a collision polygon on `brick_wall` (a full
64x64 square works fine for a wall tile). This is safer done by eye in
the editor than hand-authored in a text file, since a malformed
collision polygon can silently fail to load.

## Step 7 — Iterate

Once this first room/block works, duplicate the pattern from
`world_layout.json` (from the earlier world-map response) to lay out
a bigger level: town block, alley, building interior, etc. — same
`(col, row)` grid, same tile names, just at whatever scale you want to
build to.
