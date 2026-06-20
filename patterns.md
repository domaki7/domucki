# Common Patterns

## Viewmodel Procedural Animation
First-person weapon visuals use `ViewmodelComponent` (`src/components/viewmodel_component.gd`), parented to the Camera3D. Weapons are floating meshes (no arms/body). All motion is Tween-based with `@export` durations for tuning.

Pattern: state calls a ViewmodelComponent method (`play_attack()`, `raise_shield()`, etc.), component creates a Tween chain, emits signals at key moments (e.g., `attack_hit_point` for hitbox activation). Every `play_*` method kills the current tween before starting a new one to handle rapid state changes.

Walk bob uses a sine wave in `_process()`, toggled by `set_bobbing(active)` from RunState enter/exit.

## Debug GUI Runtime Tuning
Tabbed in-game debug panel (`src/ui/debug/`) for tweaking component `@export` vars at runtime. Alt toggles panel + mouse cursor + disables game input. Each component gets its own tab script. Features: per-value reset buttons (↺) that appear when a value is modified, checkbox toggles (e.g., attack animation loop), and "Copy Values to Clipboard" that exports only changed values as JSON. See `debug.md` for full details and how to add new tabs.

## Damage Flow
1. HitboxComponent (attacker) overlaps HurtboxComponent (target)
2. HurtboxComponent checks `is_blocking` flag:
   - If blocking and stamina available: spends `stamina.block_cost`, emits `damage_blocked(hitbox)`, no damage dealt
   - If blocking but no stamina: block fails, damage goes through normally
   - If not blocking: proceeds to step 3
3. HurtboxComponent emits `hurt(hitbox)` signal
4. HurtboxComponent calls `health_component.take_damage(hitbox.damage)`
5. HealthComponent emits `health_changed` and `damage_taken`
6. If health <= 0, HealthComponent emits `died`
7. Entity handles death (play animation, drop loot, queue_free)

## Adding a New Enemy
1. Create subfolder in `src/entities/enemies/<enemy_name>/`
2. Create scene (.tscn) with CharacterBody3D root + CollisionShape3D
3. Add component nodes as children (HealthComponent, MovementComponent, AnimationComponent, HitboxComponent, HurtboxComponent)
4. Wire references via `$NodeName` in the entity script's `_ready()`
5. Create `states/` subfolder with a base state (extends State, typed to enemy class) and concrete AI states
6. Base enemy state provides `get_player()`, `get_distance_to_player()`, `get_direction_to_player()` helpers
7. Start state machine via `call_deferred` in `_ready()`
8. Set collision layers: body layer 3 (Enemy) mask 1 (World), hitbox layer 6 mask 0, hurtbox layer 8 mask 5 (PlayerHitbox)
9. Handle death: `health_component.died` -> transition to DeathState -> disable collisions -> play death anim -> `queue_free()`

### Existing Enemies
- **Barbarian** (`src/entities/enemies/barbarian/`) -- Melee enemy using KayKit Barbarian model with 1H_Axe. States: Idle (detect player at range), Chase (run toward player), Attack (1H_Melee_Attack_Chop + hitbox), Death. 75 HP, 15 damage, move speed 3.5.

## Creating a New Item
1. If new category needed, create Resource script in `resources/items/` extending ItemData
2. Create .tres in `resources/items/definitions/`
3. Set the script and fill @export fields in inspector

## Save/Load
Saveable nodes join the `"saveable"` group and implement:
```gdscript
func save_data() -> Dictionary:
    return { "health": health_component.current_health, "position": global_position }

func load_data(data: Dictionary) -> void:
    health_component.current_health = data.get("health", health_component.max_health)
    global_position = data.get("position", Vector3.ZERO)
```
