# Zombie Survival – Godot sprite sheets

Everything from `Full_Sprite.png`, cut out (transparent background) and re-packed into one sheet per asset group.

## Install
1. Copy this folder to `res://assets/zombie_survival/` (the `.tres` files use that path; find/replace it if you put it elsewhere).
2. Project Settings → Rendering → Textures → **Default Texture Filter = Nearest** (keeps the pixel art crisp).
3. Drag `godot/player_frames.tres` etc. into an `AnimatedSprite2D`'s *Sprite Frames* slot. Verified to load in Godot 4.4.1 (headless).

## Folders
- `<group>/<name>_sheet.png` – clean sheet, transparent, tight grid (no spacing/margin) → use `hframes`/`vframes` or `AtlasTexture`.
- `<group>/<name>_sheet_guide.png` – same geometry on a checkerboard with **dotted pink cell borders** and frame names (for cropping by hand).
- `<group>/frames/<sheet>/<frame>.png` – every frame already cropped as its own PNG (cell-sized, so feet stay aligned).
- `Full_Sprite_annotated.png` – your original image with a dotted box around every element.
- `atlas.json` – frame name → x/y/w/h for every sheet.
- `godot/` – `SpriteFrames` resources, `hit_flash.gdshader`.

## Sheets
| File | Cell (px) | Grid (cols × rows) | Frames |
|---|---|---|---|
| `player/player_sheet.png` | 112×112 | 4 × 4 | 14 |
| `player/player_idle_down_anim.png` | 112×112 | 4 × 1 | 4 |
| `player/player_idle_left_anim.png` | 112×112 | 4 × 1 | 4 |
| `player/player_idle_up_anim.png` | 112×112 | 4 × 1 | 4 |
| `player/player_idle_right_anim.png` | 112×112 | 4 × 1 | 4 |
| `player/player_walk_cycle.png` | 112×112 | 4 × 4 | 16 |
| `zombies/zombie_normal_sheet.png` | 128×112 | 5 × 2 | 10 |
| `zombies/zombie_fast_sheet.png` | 128×112 | 3 × 1 | 3 |
| `zombies/zombie_tank_sheet.png` | 112×128 | 3 × 1 | 3 |
| `zombies/zombie_die_sheet.png` | 128×112 | 2 × 2 | 4 |
| `environment/environment_tiles_64.png` | 64×64 | 8 × 2 | 16 |
| `environment/environment_tiles_original_ratio.png` | 64×106 | 8 × 2 | 16 |
| `environment/props_nature_sheet.png` | 88×136 | 5 × 2 | 10 |
| `environment/props_street_sheet.png` | 120×128 | 5 × 2 | 10 |
| `environment/dustbin_hide_sheet.png` | 88×136 | 4 × 1 | 4 |
| `environment/doors_crates_sheet.png` | 64×120 | 4 × 1 | 4 |
| `items/weapons_sheet.png` | 128×72 | 4 × 2 | 8 |
| `items/pickups_sheet.png` | 72×96 | 4 × 1 | 4 |
| `ui/ui_icons_sheet.png` | 72×88 | 5 × 1 | 5 |
| `ui/ui_elements_sheet.png` | 144×72 | 5 × 1 | 5 |
| `fx/fx_particles_sheet.png` | 72×72 | 4 × 5 | 20 |
| `fx/fx_shadows_sheet.png` | 96×40 | 3 × 1 | 3 |

Frame order is left→right, top→bottom; names are in the guide images and `atlas.json`.
Tiles (row-major): dirt, grass_a, grass_b, asphalt_cracked_a, road_line, concrete_gray_spots, asphalt_cracked_b, asphalt_cracked_c (row 1) · wood_planks, concrete_light, floor_tiles_small, floor_tiles_large, sewer_grate, brick_wall, concrete_cracked, asphalt_hole (row 2). Tiles are cropped to 64×64; `dirt`, `grass_a`, `grass_b`, `concrete_light` are made seamless. The others are not designed to repeat (cracks, road line, bricks). `environment_tiles_original_ratio.png` keeps the source 64×~106 crops.

## Animations in the `.tres` files
- **player_frames**: `idle_/walk_/shoot_` × `down,left,up,right`, `hurt`, `die`. `idle_down` uses your 4-frame idle (`player_idle_down_anim.png`, scaled to the pack's 112×112 cell). `idle_left/up/right` are a procedural breathing cycle I generated from the pack's single idle poses (1px chest lift + slight widen, legs planted) so all four directions animate instead of standing frozen. Each direction's original single frame is kept as `idle_<dir>_static` if you'd rather use that. Walk is a 4-frame placeholder cycle I built from your walk/idle poses (right = mirrored left, because the source `walk_right` holds a pistol and the other directions don't).
- **zombie_normal_frames**: `walk` (5), `attack` (5), `die` (4). **zombie_fast_frames**: `run`, `die`. **zombie_tank_frames**: `walk` only (no tank death art in the pack).
- **fx_frames**: `muzzle_flash`, `impact_spark`, `blood_splash`, `dust_puff`.
- Zombies are front-facing only: rotate the node toward the player or use `flip_h`.
- All frames of a character share one cell size with feet at bottom-centre, so animations swap without jumping. Put the `AnimatedSprite2D` origin at the feet for Y-sorting (set `offset.y = -cell_h/2`).

## Added by me (not in your original)
- `player/player_walk_cycle.png` (walk cycle), `fx/fx_particles_sheet.png` (muzzle flash, spark, blood splash, dust, 4 blood decals), `fx/fx_shadows_sheet.png` (3 blob shadows, place under characters).
- `fx/frames/bullet_tracer.png`, `ui/frames/hit_marker.png`, `ui/frames/damage_vignette.png` (stretch full-screen in a `TextureRect`, raise alpha when hurt).
- `ui/frames/bar_under.png` + `bar_fill_health|stamina|armor|xp.png`: 128×24, identical size. Use as `TextureProgressBar.texture_under` / `texture_progress`; the fill area is x5–121, y5–18.
- Muzzle flash origin is the barrel tip at the left-centre of the frame; rotate the sprite around that point.
- `godot/hit_flash.gdshader`: set `flash_amount` to 1 then tween to 0 on damage.

## Known quirks of the source art
- Zombie `walk_0` is drawn slightly smaller than the other frames.
- The source `crosshair` and `reload_icon` are faint white glyphs; both are cut out with brightness-based alpha.
- The chain-link `fence` is filled dark (the mesh isn't transparent).
