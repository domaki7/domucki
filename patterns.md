# Common Patterns

## Upper/Lower Body Animation Blending
To play different animations on upper and lower body (e.g., blocking while walking), use `UpperBodyOverride` (a `SkeletonModifier3D`). The AnimationPlayer plays the base animation (legs), and the modifier overrides upper body bone poses after animation processing. Do NOT use `set_bone_pose_rotation()` in `_process()` -- the AnimationMixer overwrites it. `SkeletonModifier3D` runs at the correct point in the skeleton pipeline.

Setup: cache bone poses from the overlay animation, define lower body bones to exclude, add the modifier as a child of `Skeleton3D`, toggle `active` on/off. See `player.gd:_setup_upper_body_override()` for the full pattern.

## Damage Flow
1. HitboxComponent (attacker) overlaps HurtboxComponent (target)
2. HurtboxComponent emits `hurt(hitbox)` signal
3. Entity or HurtboxComponent calls `health_component.take_damage(hitbox.damage)`
4. HealthComponent emits `health_changed` and `damage_taken`
5. If health <= 0, HealthComponent emits `died`
6. Entity handles death (play animation, drop loot, queue_free)

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
