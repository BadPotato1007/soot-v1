# soot-v1

`soot-v1` is a Godot project repository containing multiple development snapshots of **soot**, with the latest playable build currently in **`/v1.8`**.

## Project Overview

The project combines multiple gameplay segments and transitions:
- Top-down combat stages with shooting, thrown weapons, and body-swapping (“hotswitch”) mechanics
- Side-scrolling/running sections in Act 2
- Narrative/ending scenes (including void/desktop ending sequences)

## Engine & Version

- **Engine:** Godot
- **Target version:** `4.7` (from `v1.8/project.godot`)
- **Main scene:** `res://scenes/StartMenu.tscn`

## How to Run

1. Open Godot `4.7`.
2. Import the project from:
   - `/home/runner/work/soot-v1/soot-v1/v1.8/project.godot`
3. Press **Play** in the editor.

## Controls (v1.8)

- **Move:** `WASD` or arrow keys
- **Attack / Shoot:** Left mouse button
- **Throw weapon:** Right mouse button or `Space`
- **Hotswitch:** `X`
- **Restart level:** `R`
- **Menu back/cancel:** `Esc`

## Repository Structure

- `v1.8/` – latest main project snapshot
- `v1.1` to `v1.7/`, `v0.x/`, `c2c/`, `soot-dmgv0.1/` – earlier iterations and variants

## Key v1.8 Paths

- `v1.8/project.godot` – Godot project configuration
- `v1.8/scenes/` – scenes for menus, levels, combat, and endings
- `v1.8/scripts/` – gameplay and system logic
- `v1.8/assets/` – art/audio and other project assets

## Notes

- The repository stores multiple historical versions; if you only want the current build, work in `v1.8/`.
