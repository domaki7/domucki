# Domucki

3D third-person action RPG built in Godot 4.7 with GDScript. Uses Jolt Physics, Forward Plus rendering, D3D12.

## Architecture

Component-based entity composition. Entities (player, enemies, NPCs) are CharacterBody3D scenes that compose reusable Component nodes as children. Components are standalone -- they carry their own logic and expose @export vars for designer tuning.

### Core Rules

1. **Every tunable value must be @export.** Never hardcode numbers that a designer might want to change. Health, speed, damage, ranges, durations, cooldowns -- all @export.
2. **Components are reusable nodes.** Each component is a .tscn with a root script. Instance it as a child of any entity that needs that behavior. Do not put component logic in the entity script.
3. **Entity scripts are thin.** The entity .gd file wires components together and handles entity-specific input or orchestration. It should not contain health logic, movement math, or inventory management -- those belong in components.
4. **Static typing everywhere.** Every variable, parameter, and return type must have an explicit type annotation. Use `-> void` on all functions that return nothing.
5. **No magic strings for node paths.** Entity scripts wire component references via `$NodeName` in `_ready()`. Components find their owner entity via `get_parent()`. Never use string-based `get_node("../SomeComponent")` with relative paths.
6. **Signals for events, methods for commands.** Components emit signals when something happens (died, health_changed). Other nodes call methods to make things happen (take_damage, heal).

## Directory Structure

```
res://
  src/components/       Reusable component nodes (.gd + .tscn pairs)
  src/entities/         Entity scenes that compose components
    player/             Player character, camera, player-specific states
    enemies/            Enemy types, each in own subfolder with states
    npcs/               NPC types
  src/systems/          Autoloaded singletons (GameManager, EventBus, etc.)
  src/states/           Base state machine framework (State, StateMachine)
  src/ui/               All UI (hud/, menus/, inventory/, dialog/)
  resources/            Custom Resource scripts and .tres data files
    items/              ItemData, WeaponData, etc. + definitions/ for .tres
    stats/              CharacterStats, StatModifier resources
    loot_tables/        LootTable resources
  levels/               Level/world scenes
  assets/               Raw assets only (models/, textures/, audio/, materials/, fonts/, shaders/)
  addons/               Third-party editor plugins and asset packs
    kaykit_character_pack_adventures/  KayKit Adventurers (CC0) -- characters, weapons, textures
```

## Naming Conventions

- **Files:** `snake_case` for everything (.gd, .tscn, .tres, directories)
- **Node names:** `PascalCase` in scene tree (HealthComponent, PlayerCamera)
- **class_name:** `PascalCase` matching the concept (HealthComponent, ItemData, PlayerIdleState)
- **Signals:** `snake_case`, past tense for events: `died`, `health_changed`, `item_added`
- **Signal handlers:** `_on_<emitter_node_name>_<signal_name>`
- **Variables/functions:** `snake_case`. Private with `_` prefix. Booleans use `is_`/`has_`/`can_` prefix.
- **Constants:** `SCREAMING_SNAKE_CASE`
- **Enums:** `PascalCase` name, `SCREAMING_SNAKE_CASE` values

## Autoloads

Registered in project.godot. Access globally by name. **Autoload scripts must NOT use `class_name`** -- the autoload name already registers a global identifier, and `class_name` with the same name causes a parser error.

- **GameManager** -- game state (playing/paused/loading), current player reference, difficulty
- **EventBus** -- signal-only singleton for decoupled cross-system events. No logic, only signal declarations.
- **SaveManager** -- save/load to user://, save slots, serialization
- **AudioManager** -- SFX/music playback, audio bus management, pooling
- **SceneManager** -- async level transitions with loading screen, fade effects

## Component Pattern

### Creating a New Component

1. Create `src/components/my_component.gd`:

```gdscript
class_name MyComponent
extends Node

signal something_happened(value: float)

@export var my_value: float = 10.0
@export var my_flag: bool = true

func do_thing() -> void:
    something_happened.emit(my_value)
```

2. Create `src/components/my_component.tscn` with that script as root node. Add any child nodes the component needs (CollisionShape3D for Area3D components, Timer nodes, etc.).

3. Instance the .tscn as a child of any entity that needs it.

### Component Communication

**Direct references (required dependencies):**
```gdscript
# Entity script wires in _ready():
health_component = $HealthComponent as HealthComponent
# Component finds its body in _ready():
body = get_parent() as CharacterBody3D
```
Entity scripts use `$NodeName` to get component references. Components use `get_parent()` to find their owning entity.

**Local signals (same-entity events):**
```gdscript
# Component emits:
signal died
# Entity script or sibling connects in _ready():
health_component.died.connect(_on_health_component_died)
```

**EventBus (cross-system events):**
```gdscript
EventBus.entity_died.emit(owner)
EventBus.entity_died.connect(_on_entity_died)
```

**Rule:** @export reference for "I need to call your methods." Signal for "I'm announcing something happened." EventBus for "Systems that don't know about me need to react."

### Existing Components

- **HealthComponent** (`src/components/health_component.gd`) -- HP tracking, `take_damage()`, `heal()`. Signals: `died`, `health_changed`, `damage_taken`, `healed`. Emits `EventBus.entity_died` on death.
- **MovementComponent** (`src/components/movement_component.gd`) -- Movement, gravity, rotation for CharacterBody3D. Finds its body via `get_parent()`. Call `apply_movement(direction, delta)`, `apply_gravity(delta)`, `apply_friction(delta)`, `move()`. Does NOT read input -- receives direction from caller.
- **AnimationComponent** (`src/components/animation_component.gd`) -- AnimationPlayer wrapper. Auto-discovers AnimationPlayer by searching sibling nodes. Call `play(animation_name, crossfade, loop)`. Pass `loop = true` for animations that should repeat (Idle, Running); omit or pass `false` for one-shot animations (attacks). Emits `animation_finished` only for non-looping animations.
- **UpperBodyOverride** (`src/components/upper_body_override.gd`) -- SkeletonModifier3D that overrides upper body bone poses after animation. Added as a child of Skeleton3D at runtime. Set `bone_poses` dictionary (bone_idx -> {"rotation": Quaternion, "position": Vector3}), toggle `active` to enable/disable. Used for shield blocking while walking.

## State Machine Pattern

States are Node children of a StateMachineComponent. Each state extends the base State class.

### Creating Entity States

1. Create a base state for the entity type if needed (e.g., `PlayerState extends State` with a typed player reference).
2. Create concrete states in `src/entities/<entity>/states/`.
3. Each state calls `transition_requested.emit(self, &"TargetStateName")` to request transitions.
4. State node names in the scene tree must match the StringName used in transitions: node `IdleState` -> `&"IdleState"`.

### State Machine Initialization

Do NOT use `initial_state` export on StateMachine for entities that need component references. Instead, the entity script starts the state machine via `call_deferred` after wiring all references in `_ready()`:
```gdscript
func _ready() -> void:
    state_machine = $StateMachine as StateMachine
    movement_component = $MovementComponent as MovementComponent
    # ... wire other references ...
    _start_state_machine.call_deferred()

func _start_state_machine() -> void:
    state_machine.transition_to(&"IdleState")
```
Entity-specific base states (e.g., `PlayerState`) use `await owner.ready` in `_ready()` to get references after the entity has wired them. The deferred start ensures all `_ready()` and await continuations complete before `enter()` is called.

## Player Entity

Player scene tree (`src/entities/player/player.tscn`):
```
Player (CharacterBody3D)         player.gd, layer 2, mask 1
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
  MovementComponent              movement_component.gd
  HealthComponent                health_component.gd
  AnimationComponent             animation_component.gd
```

### Player States

All extend `PlayerState` (`src/entities/player/states/player_state.gd`), which provides `player`, `movement`, `animation` refs and `get_input_direction() -> Vector3` (camera-relative WASD).

- **IdleState** -- plays `Idle`, transitions to RunState on movement input, AttackState on LMB
- **RunState** -- plays `Running_A`, applies camera-relative movement + rotation, transitions to IdleState when stopped
- **AttackState** -- plays `1H_Melee_Attack_Slice_Diagonal`, applies friction (no movement input), transitions out on animation_finished
- **DefendState** -- raises shield via UpperBodyOverride (upper body holds Blocking pose), plays `Walking_A`/`Idle` as base for legs, allows movement at half speed, transitions to Idle/Run on RMB release

### Input Actions

| Action | Key | Used by |
|--------|-----|---------|
| `move_forward` | W | PlayerState.get_input_direction() |
| `move_backward` | S | PlayerState.get_input_direction() |
| `move_left` | A | PlayerState.get_input_direction() |
| `move_right` | D | PlayerState.get_input_direction() |
| `attack` | LMB | IdleState, RunState |
| `defend` | RMB | IdleState, RunState |

### KayKit Adventurers Asset Pack

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

## GDScript Style

```gdscript
class_name MyClassName
extends ParentClass

signal my_signal(param: float)

enum MyEnum { VALUE_A, VALUE_B, VALUE_C }

const MAX_VALUE: int = 100

@export var speed: float = 5.0
@export var max_health: float = 100.0
@export_group("Combat")
@export var damage: float = 10.0
@export var attack_range: float = 2.0
var health_component: HealthComponent
var _internal_state: int = 0

func _ready() -> void:
    health_component = $HealthComponent as HealthComponent

func _physics_process(delta: float) -> void:
    pass

func _unhandled_input(event: InputEvent) -> void:
    pass

func do_public_thing(value: float) -> bool:
    return value > 0.0

func _calculate_internal(x: float) -> float:
    return x * 2.0

func _on_health_component_died() -> void:
    queue_free()
```

### Script Section Order

1. class_name and extends
2. Signals
3. Enums
4. Constants
5. @export vars (grouped with @export_group)
6. @onready vars
7. Regular vars (public then private)
8. _ready, _process, _physics_process, _input/_unhandled_input
9. Public methods
10. Private methods
11. Signal handlers

### Type Annotations -- Always Explicit

```gdscript
var health: float = 100.0
var items: Array[ItemData] = []
var target: Node3D = null
func calculate(base: float, modifier: float) -> float:
```

### @export Grouping

```gdscript
@export_group("Movement")
@export var speed: float = 5.0
@export var jump_force: float = 8.0

@export_group("Combat")
@export var damage: float = 10.0
@export var attack_cooldown: float = 0.5

```

Component references are wired via `$NodeName` in `_ready()`, not `@export`.

## Physics Collision Layers

| Layer | Name | Purpose |
|-------|------|---------|
| 1 | World | Environment geometry |
| 2 | Player | Player body |
| 3 | Enemy | Enemy bodies |
| 4 | NPC | NPC bodies |
| 5 | PlayerHitbox | Player attack hitboxes |
| 6 | EnemyHitbox | Enemy attack hitboxes |
| 7 | PlayerHurtbox | Player hurtboxes |
| 8 | EnemyHurtbox | Enemy hurtboxes |
| 9 | Interactable | Interactable objects/NPCs |
| 10 | Projectile | Projectiles |
| 11 | NavObstacle | Navigation obstacles |
| 12 | Trigger | Trigger zones |

## Common Patterns

### Upper/Lower Body Animation Blending
To play different animations on upper and lower body (e.g., blocking while walking), use `UpperBodyOverride` (a `SkeletonModifier3D`). The AnimationPlayer plays the base animation (legs), and the modifier overrides upper body bone poses after animation processing. Do NOT use `set_bone_pose_rotation()` in `_process()` -- the AnimationMixer overwrites it. `SkeletonModifier3D` runs at the correct point in the skeleton pipeline.

Setup: cache bone poses from the overlay animation, define lower body bones to exclude, add the modifier as a child of `Skeleton3D`, toggle `active` on/off. See `player.gd:_setup_upper_body_override()` for the full pattern.

### Damage Flow
1. HitboxComponent (attacker) overlaps HurtboxComponent (target)
2. HurtboxComponent emits `hurt(hitbox)` signal
3. Entity or HurtboxComponent calls `health_component.take_damage(hitbox.damage)`
4. HealthComponent emits `health_changed` and `damage_taken`
5. If health <= 0, HealthComponent emits `died`
6. Entity handles death (play animation, drop loot, queue_free)

### Adding a New Enemy
1. Create subfolder in `src/entities/enemies/<enemy_name>/`
2. Create scene (.tscn) with CharacterBody3D root + CollisionShape3D
3. Add component nodes as children (HealthComponent, MovementComponent, AnimationComponent, etc.)
4. Wire references via `$NodeName` in the entity script's `_ready()`
5. Create `states/` subfolder with AI states
6. Start state machine via `call_deferred` in `_ready()`
7. Assign loot table .tres and set collision layers

### Creating a New Item
1. If new category needed, create Resource script in `resources/items/` extending ItemData
2. Create .tres in `resources/items/definitions/`
3. Set the script and fill @export fields in inspector

### Save/Load
Saveable nodes join the `"saveable"` group and implement:
```gdscript
func save_data() -> Dictionary:
    return { "health": health_component.current_health, "position": global_position }

func load_data(data: Dictionary) -> void:
    health_component.current_health = data.get("health", health_component.max_health)
    global_position = data.get("position", Vector3.ZERO)
```
