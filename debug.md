# Debug GUI

In-game debug panel for tweaking `@export` variables at runtime. Press **Alt** to toggle: shows the panel, releases the mouse cursor, and disables all game input (movement, attack, defend, jump). Press Alt again to hide and resume gameplay.

## Architecture

The debug GUI is a **tabbed system** managed by `debug_gui.gd`. The master controller handles Alt key toggle, mouse cursor, and a TabContainer. Each tab is a separate script extending Control that receives its target component via `setup()` and builds controls programmatically.

Located in `src/ui/debug/`. Instanced as a child of the HUD scene (`src/ui/hud/hud.tscn`).

## Current Tabs

- **Viewmodel** (`src/ui/debug/debug_viewmodel_gui.gd`) -- tweaks ViewmodelComponent positions, rotations, durations, attack direction offsets, bob, and scale. Has per-value reset buttons (↺) that appear when modified, a "Loop Attack Animation" checkbox for visual-only attack previewing, and "Copy Values to Clipboard" that exports only changed values as JSON.
- **Stamina** (`src/ui/debug/debug_stamina_gui.gd`) -- tweaks StaminaComponent values: max_stamina, regen_rate, regen_delay, sprint_drain_rate, jump_cost, attack_cost, block_cost. Per-value reset buttons and "Copy Values to Clipboard".
- **Combat** (`src/ui/debug/debug_combat_gui.gd`) -- tweaks hitbox/hurtbox collision shapes for both player and all enemies. Player and enemy sections each have an "Invulnerable" checkbox that toggles `HealthComponent.is_invulnerable`. Player Hitbox: radius (SphereShape3D), position offset. Player Hitbox Swing Arc: windup offset, hit offset, windup/hit/recovery durations. Player Hurtbox: radius, height (CapsuleShape3D), position offset. Enemy Hitbox and Enemy Hitbox Swing Arc sections mirror the player controls and apply to all enemies. Each section has a "Show Hitbox/Hurtbox" checkbox that creates semi-transparent mesh overlays (red for hitbox, blue for hurtbox) visible through walls. Overlays update in real-time when shape values change. Auto-discovers enemies via `"enemies"` group and applies current values (including invulnerability and swing arc settings) to newly spawned enemies. Per-value reset buttons and "Copy Values to Clipboard".

## Adding a New Debug Tab

1. Create `src/ui/debug/debug_<component>_gui.gd` extending Control
2. Add a `setup(component: <ComponentType>) -> void` method that stores the reference and calls `_build_controls()`
3. In `_ready()`, create a ScrollContainer + VBoxContainer for the tab's content. **Important:** call `_scroll.set_anchors_preset(Control.PRESET_FULL_RECT)` on the ScrollContainer so it fills the tab area (plain Control parents don't respect `size_flags`).
4. Build controls programmatically in `_build_controls()`:
   - `_add_header(group_name)` for section labels
   - `_add_float_control(property, min, max, step)` for float exports (includes per-value reset button)
   - `_add_vector3_control(property, min, max, step)` for Vector3 exports (includes per-axis reset buttons)
   - `_add_checkbox_control(label, callback)` for boolean toggles (returns CheckBox)
5. On value change, write directly to the component property. For position/rotation properties that need immediate visual feedback, also update the relevant node transforms. Reset buttons (↺) auto-show when a value differs from its default and auto-hide when reset.
6. Add a "Copy Values to Clipboard" button that serializes only changed values to JSON via `DisplayServer.clipboard_set()`
7. Register the tab in `debug_gui.gd`'s `_bind_to_player()` method: instantiate the script, set `name` (used as tab label), add to TabContainer, call `setup()`

## Input Guard

When the debug panel is visible (`Input.mouse_mode == MOUSE_MODE_VISIBLE`):
- `FirstPersonCamera._unhandled_input()` skips mouse look processing
- `PlayerState._is_input_enabled()` returns `false`, blocking all movement, attack, defend, jump, and sprint input
- All states guard their `Input.is_action_just_pressed()` calls with `_is_input_enabled()`

## Export Format

The "Copy Values to Clipboard" button produces JSON containing only properties that differ from their defaults:
```json
{
  "property_name": 0.5,
  "vector3_property": { "x": 0.1, "y": -0.2, "z": 0.3 }
}
```
If no values have been changed, the output is `{}`. Paste this to Claude to apply values to the scene/script defaults.
