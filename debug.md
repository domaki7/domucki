# Debug GUI

In-game debug panel for tweaking `@export` variables at runtime. Press **Alt** to toggle: shows the panel, releases the mouse cursor, and disables all game input (movement, attack, defend, jump). Press Alt again to hide and resume gameplay.

## Architecture

The debug GUI is a **tabbed generic system**. Each tab targets a different component and auto-discovers its `@export` vars to build controls (SpinBox for floats, 3x SpinBox row for Vector3). New tabs are added as the game grows -- one tab per component that needs runtime tuning.

Located in `src/ui/debug/`. Instanced as a child of the HUD scene (`src/ui/hud/hud.tscn`).

## Current Tabs

- **Viewmodel** (`src/ui/debug/debug_viewmodel_gui.gd`) -- tweaks ViewmodelComponent positions, rotations, durations, bob, and scale. Has "Copy Values to Clipboard" button that exports all values as JSON for pasting.

## Adding a New Debug Tab

1. Create `src/ui/debug/debug_<component>_gui.gd` extending Control
2. Get the target component reference via `GameManager.player.<component>` (same pattern as the viewmodel tab)
3. Build controls programmatically in `_build_controls()`:
   - `_add_header(group_name)` for section labels
   - `_add_float_control(property, min, max, step)` for float exports
   - `_add_vector3_control(property, min, max, step)` for Vector3 exports
4. On value change, write directly to the component property. For position/rotation properties that need immediate visual feedback, also update the relevant node transforms
5. Add a "Copy Values to Clipboard" button that serializes to JSON via `DisplayServer.clipboard_set()`
6. Instance the new tab in the debug GUI system

## Input Guard

When the debug panel is visible (`Input.mouse_mode == MOUSE_MODE_VISIBLE`):
- `FirstPersonCamera._unhandled_input()` skips mouse look processing
- `PlayerState._is_input_enabled()` returns `false`, blocking all movement, attack, defend, and jump input
- All states guard their `Input.is_action_just_pressed()` calls with `_is_input_enabled()`

## Export Format

The "Copy Values to Clipboard" button produces JSON:
```json
{
  "property_name": 0.5,
  "vector3_property": { "x": 0.1, "y": -0.2, "z": 0.3 }
}
```
Paste this to Claude to apply values to the scene/script defaults.
