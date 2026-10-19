# Post-Apocalyptic World Pack — reskinned from "Tiny Swords (Free Pack)"

Everything here started as the medieval-fantasy **Tiny Swords** pack you uploaded. I picked the
pieces that make sense for a zombie game (buildings, nature, ground, a couple of resource props,
fire/explosion/dust FX) and ran them through a decay/desaturation pipeline: lower saturation,
a dark-brown/olive-grey duotone grade, procedural grime/soot, rust streaks, crack lines, and
punched-out holes for broken roofs and leaf-loss on trees. Units and most UI (banners, medieval
icons, soldier sprites) were **skipped** — they don't fit a zombie shooter. Say the word if you
actually want any of that reskinned too.

## ⚠️ Read this before you drop it into your project
This pack is a **different, larger, more painterly art style** than your `zombie_survival` player/
zombie sprites (those are ~80px tall, flat top-down; these buildings/trees are ~150–320px,
semi-isometric RTS art). See `mockup_scene.png` — it's an honest side-by-side, not a cherry-picked
angle. Use this pack for:
- A stylized **overworld/map screen**, cutscene backdrop, or main-menu scene, or
- **Silhouette/color reference** while you draw matching top-down props, or
- If you don't mind the scale/perspective mismatch for a first prototype.

It is **not** a perspective-matched drop-in for the top-down gameplay sprites from the other zip
without rescaling and probably redrawing the ground-contact shadows.

## What's inside
| Folder | Contents |
|---|---|
| `buildings/` | `ruined_house_1/2/3`, `ruined_archery`, `ruined_barracks`, `ruined_monastery`, `ruined_tower`, `ruined_castle` |
| `nature/` | `dead_tree_1–4`, `dry_bush_1–4`, `rubble_rock_1–4` |
| `ground/` | `wasteland_dirt_64.png`, `scorched_ground_64.png` (both genuinely **seamless** — checked in a 3×3 tile), `rubble_concrete_64_NOT_SEAMLESS.png` (the source stone has periodic grout lines that wouldn't blend cleanly — use as a one-off decal, not a tiling floor) |
| `resources/` | `scrap_wood_pile` (from the Wood resource), `spent_casing_pile` (the Gold resource, hue-shifted from gold to brass so it reads as a pile of spent shell casings — a deliberate reinterpretation, not a literal recolor), `spoiled_meat_pile` |
| `fx/` | `fire`, `explosion`, `dust` — these already fit a wasteland, so they're only lightly graded; each file is still the original multi-frame animation strip |
| `godot/wasteland_tileset.tres` | A Godot `TileSet` with the two seamless ground tiles as atlas sources. Loads clean in Godot 4.4.1 (verified headless: 2 sources). |
| `*_guide.png` next to every item | Same image on a checkerboard with the filename printed on it — for quickly IDing pieces in a folder view. |
| `mockup_scene.png` | The scale/style reality-check image described above. |
| `manifest.json` | name → file path/size for every item. |

## Install
Copy the folder to `res://assets/post_apoc_world/` (matches the path baked into `wasteland_tileset.tres`;
find/replace if you place it elsewhere).

## Honest limitations
- **Scale mismatch** with your existing top-down pack (see above) — the single biggest caveat.
- **Only one ground texture from the source tileset was usable as a clean seamless tile** (the fill
  interior of the grass patch). The source is an edge/corner "autotile" set (grass patch with a leafy
  scalloped border, cliff-face columns), not a set of plain repeating floor tiles — I did not attempt to
  rebuild a full 47-tile autotile blob set from it.
- `spent_casing_pile` and `spoiled_meat_pile` are creative reinterpretations of the Gold/Meat resources,
  not neutral recolors — check they read the way you want before using them in-game.
- Damage (holes/cracks/rust) is procedural and random-seeded, so if you regenerate you'll get different
  damage patterns, not these exact ones.
- Units (Archer/Lancer/Monk/Pawn/Warrior × 5 factions) and most UI Elements (banners, medieval icons,
  bars, cursors) from the source pack were not touched.
