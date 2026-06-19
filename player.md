# Player Entity

Player scene tree (`src/entities/player/player.tscn`):
```
Player (CharacterBody3D)         player.gd, layer 2, mask 1+3
  CollisionShape3D               CapsuleShape3D
  KnightModel                    KayKit Knight.glb instance, rotated 180° Y
  CameraArm                      camera_arm.gd, third-person orbit camera
    SpringArm3D                  wall collision, length 4.0
      Camera3D
  StateMachine                   state_machine.gd
    IdleState                    idle_state.gd
    RunState                     run_state.gd
    AttackState                  attack_state.gd
    DefendState                  defend_state.gd
    DeathState                   death_state.gd
  MovementComponent              movement_component.gd
  HealthComponent                health_component.gd
  AnimationComponent             animation_component.gd
  HitboxComponent                hitbox_component.gd, layer 5 (PlayerHitbox), damage 25
    CollisionShape3D             SphereShape3D r=0.6 at (0, 0.5, -0.8)
  HurtboxComponent               hurtbox_component.gd, layer 7 (PlayerHurtbox), mask 6 (EnemyHitbox)
    CollisionShape3D             CapsuleShape3D matching body
```

## Player States

All extend `PlayerState` (`src/entities/player/states/player_state.gd`), which provides `player`, `movement`, `animation`, `hitbox` refs and `get_input_direction() -> Vector3` (camera-relative WASD).

- **IdleState** -- plays `Idle`, transitions to RunState on movement input, AttackState on LMB
- **RunState** -- plays `Running_A`, applies camera-relative movement + rotation, transitions to IdleState when stopped
- **AttackState** -- plays `1H_Melee_Attack_Slice_Diagonal`, activates hitbox on enter / deactivates on exit, applies friction (no movement input), transitions out on animation_finished
- **DefendState** -- raises shield via UpperBodyOverride (upper body holds Blocking pose), plays `Walking_A`/`Idle` as base for legs, allows movement at half speed, transitions to Idle/Run on RMB release
- **DeathState** -- terminal state, plays `Death_A`, deactivates hitbox, disables defend, applies gravity/friction. After animation finishes + 1s delay, reloads current level via SceneManager

## Input Actions

| Action | Key | Used by |
|--------|-----|---------|
| `move_forward` | W | PlayerState.get_input_direction() |
| `move_backward` | S | PlayerState.get_input_direction() |
| `move_left` | A | PlayerState.get_input_direction() |
| `move_right` | D | PlayerState.get_input_direction() |
| `attack` | LMB | IdleState, RunState |
| `defend` | RMB | IdleState, RunState |

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
