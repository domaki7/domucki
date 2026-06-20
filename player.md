# Player Entity

Player scene tree (`src/entities/player/player.tscn`):
```
Player (CharacterBody3D)         player.gd, layer 2, mask 1+3
  CollisionShape3D               CapsuleShape3D
  KnightModel                    Knight.glb instance, visible=false (kept for animation timing)
  FirstPersonCamera (Node3D)     first_person_camera.gd, Y=1.0 (eye height)
    Camera3D                     FOV 75, near=0.05
      ViewmodelComponent         viewmodel_component.gd
        SwordPivot               Node3D, lower-right
          SwordMesh              MeshInstance3D (1H_Sword from Knight.glb)
        ShieldPivot              Node3D, lower-left
          ShieldMesh             MeshInstance3D (Round_Shield from Knight.glb)
  StateMachine                   state_machine.gd
    IdleState                    idle_state.gd
    RunState                     run_state.gd
    AttackState                  attack_state.gd
    DefendState                  defend_state.gd
    DeathState                   death_state.gd
    JumpState                    jump_state.gd
    AirAttackState               air_attack_state.gd
  MovementComponent              movement_component.gd, fps_mode=true
  HealthComponent                health_component.gd
  AnimationComponent             animation_component.gd (plays on hidden model)
  HitboxComponent                hitbox_component.gd, layer 5 (PlayerHitbox), damage 25
    CollisionShape3D             SphereShape3D r=0.6 at (0, 0.5, -0.8)
  HurtboxComponent               hurtbox_component.gd, layer 7 (PlayerHurtbox), mask 6 (EnemyHitbox)
    CollisionShape3D             CapsuleShape3D matching body
```

## First-Person Camera

`FirstPersonCamera` (`src/entities/player/first_person_camera.gd`) handles mouse look. Yaw rotates the Player CharacterBody3D (`owner.rotation.y`), pitch rotates the camera node (`self.rotation.x`). Camera is parented to Player (not `top_level`), so it moves with the body. Pitch clamped to -80°/+80°.

## Viewmodel System

`ViewmodelComponent` (`src/components/viewmodel_component.gd`) manages first-person weapon display. Parented to Camera3D, moves/rotates with the camera. Extracts 1H_Sword and Round_Shield meshes from Knight.glb at runtime. Each weapon has two uniform `@export float` scale controls: `*_mesh_scale` (scales the mesh only) and `*_pivot_scale` (scales the pivot, affecting both mesh size and animation reach).

**Procedural animations** (all Tween-based, all `@export` durations and offsets):
- `play_attack()` -- windup → swing → recovery. Swing direction controlled by 4 `@export` Vector3 offsets: `attack_windup_rotation_offset`, `attack_windup_position_offset`, `attack_swing_rotation_offset`, `attack_swing_position_offset`. Emits `attack_hit_point` at swing peak (for hitbox activation) and `attack_finished` when done.
- `play_attack_visual()` -- same tween as `play_attack()` but skips `attack_hit_point` signal. Used by the debug GUI's attack loop for visual-only previewing.
- `raise_shield()` / `lower_shield()` -- tweens shield to/from raised position on left side.
- `play_death()` -- drops both weapons downward, emits `death_finished`.
- `set_bobbing(active)` -- sine-wave bob on weapon pivots while walking.

## Player States

All extend `PlayerState` (`src/entities/player/states/player_state.gd`), which provides `player`, `movement`, `animation`, `hitbox`, `viewmodel` refs, `get_input_direction() -> Vector3` (camera-relative WASD), `_check_jump() -> bool` (transitions to JumpState if Space pressed and on floor), and `_is_input_enabled() -> bool` (returns false when mouse is visible, e.g. debug GUI open). All input checks in states are guarded by `_is_input_enabled()`.

- **IdleState** -- plays `Idle` (hidden model), disables viewmodel bob, transitions to RunState on movement input, AttackState on LMB
- **RunState** -- plays `Running_A` (hidden model), enables viewmodel bob, applies camera-relative movement, transitions to IdleState when stopped
- **AttackState** -- calls `viewmodel.play_attack()`, activates hitbox on `attack_hit_point` signal, deactivates on `attack_finished`, transitions to Idle/Run
- **DefendState** -- calls `viewmodel.raise_shield()` on enter, `lower_shield()` on exit, allows half-speed movement, transitions to Idle/Run on RMB release
- **JumpState** -- phased jump with internal START/AIR/LAND phases. Uses hidden model's animation timing for phase transitions. Disables viewmodel bob. Supports re-entry to AIR phase via `return_to_air` flag (used by AirAttackState).
- **AirAttackState** -- mid-air attack via `viewmodel.play_attack()`, hitbox activated on `attack_hit_point`, gravity + full air control. On `attack_finished`: if on floor transitions to Idle/Run, if airborne returns to JumpState(AIR).
- **DeathState** -- terminal state, calls `viewmodel.play_death()`, deactivates hitbox. After `death_finished` + 1s delay, reloads current level via SceneManager

## Input Actions

| Action | Key | Used by |
|--------|-----|---------|
| `move_forward` | W | PlayerState.get_input_direction() |
| `move_backward` | S | PlayerState.get_input_direction() |
| `move_left` | A | PlayerState.get_input_direction() |
| `move_right` | D | PlayerState.get_input_direction() |
| `attack` | LMB | IdleState, RunState, JumpState(AIR) |
| `defend` | RMB | IdleState, RunState |
| `jump` | Space | All grounded states (via PlayerState._check_jump) |
| (Alt key) | Alt | Debug GUI toggle (debug_viewmodel_gui.gd) |

## KayKit Adventurers Asset Pack

CC0 licensed characters in `addons/kaykit_character_pack_adventures/`. Characters: Knight, Barbarian, Mage, Rogue, Rogue_Hooded. Each .glb has 70+ animations including Idle, Walking_A/B/C, Running_A/B, attack variants (1H/2H/Dualwield), Death_A/B, Dodge, Block, Spellcast, Jump, and more. Weapons and accessories in `Assets/gltf/`.

**Model orientation:** KayKit GLB models face +Z at rest, but Godot and MovementComponent assume -Z forward. When instancing a KayKit model in an entity scene, apply a 180° Y rotation on the model node: `Transform3D(-1, 0, 0, 0, 1, 0, 0, 0, -1, 0, 0, 0)`. Do NOT change the MovementComponent atan2 formula to compensate -- correct at the model node level.

**Built-in equipment meshes:** KayKit character GLBs have all weapon/shield/accessory variants pre-attached to bone slots and **all visible by default**. The entity script must hide unwanted variants in `_ready()`. Skeleton structure for equipment slots:
- `handslot_l` (BoneAttachment3D on `handslot.l`) -- left hand equipment (shields, offhand weapons)
- `handslot_r` (BoneAttachment3D on `handslot.r`) -- right hand equipment (main-hand weapons)
- `head` (BoneAttachment3D on `head`) -- helmets
- `chest` (BoneAttachment3D on `chest`) -- capes, armor accessories

Knight model equipment meshes:
- Left hand: `1H_Sword_Offhand`, `Badge_Shield`, `Rectangle_Shield`, `Round_Shield`, `Spike_Shield`
- Right hand: `1H_Sword`, `2H_Sword`
- Head: `Knight_Helmet`
- Chest: `Knight_Cape`
