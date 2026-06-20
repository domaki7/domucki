# Architecture

Component-based entity composition. Entities (player, enemies, NPCs) are CharacterBody3D scenes that compose reusable Component nodes as children. Components are standalone -- they carry their own logic and expose @export vars for designer tuning.

## Core Rules

1. **Every tunable value must be @export.** Never hardcode numbers that a designer might want to change. Health, speed, damage, ranges, durations, cooldowns -- all @export.
2. **Components are reusable nodes.** Each component is a .tscn with a root script. Instance it as a child of any entity that needs that behavior. Do not put component logic in the entity script.
3. **Entity scripts are thin.** The entity .gd file wires components together and handles entity-specific input or orchestration. It should not contain health logic, movement math, or inventory management -- those belong in components.
4. **Static typing everywhere.** Every variable, parameter, and return type must have an explicit type annotation. Use `-> void` on all functions that return nothing.
5. **No magic strings for node paths.** Entity scripts wire component references via `$NodeName` in `_ready()`. Components find their owner entity via `get_parent()`. Never use string-based `get_node("../SomeComponent")` with relative paths.
6. **Signals for events, methods for commands.** Components emit signals when something happens (died, health_changed). Other nodes call methods to make things happen (take_damage, heal).

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
- **MovementComponent** (`src/components/movement_component.gd`) -- Movement, gravity, rotation for CharacterBody3D. Finds its body via `get_parent()`. Call `apply_movement(direction, delta)`, `apply_gravity(delta)`, `apply_friction(delta)`, `move()`. Does NOT read input -- receives direction from caller. Set `fps_mode = true` to disable body rotation toward movement direction (body yaw controlled by camera instead).
- **AnimationComponent** (`src/components/animation_component.gd`) -- AnimationPlayer wrapper. Auto-discovers AnimationPlayer by searching sibling nodes. Call `play(animation_name, crossfade, loop)`. Pass `loop = true` for animations that should repeat (Idle, Running); omit or pass `false` for one-shot animations (attacks). Emits `animation_finished` only for non-looping animations.
- **HitboxComponent** (`src/components/hitbox_component.gd`) -- Area3D that deals damage on overlap. `@export damage`. Starts deactivated. Call `activate()` / `deactivate()` to toggle CollisionShape3D. Set `monitoring = false`, `monitorable = true` so hurtboxes detect it. Emits `hit(hurtbox)`.
- **HurtboxComponent** (`src/components/hurtbox_component.gd`) -- Area3D that receives damage. `@export health_component` (auto-discovers from siblings if unset). Set `monitoring = true`, `monitorable = false`. On overlap with HitboxComponent, emits `hurt(hitbox)` and calls `health_component.take_damage()`.
- **ViewmodelComponent** (`src/components/viewmodel_component.gd`) -- First-person weapon display. Parented to Camera3D, manages sword and shield meshes (extracted from Knight.glb at runtime). Procedural Tween-based animations: `play_attack()`, `raise_shield()`/`lower_shield()`, `play_death()`, `set_bobbing()`. Signals: `attack_hit_point`, `attack_finished`, `death_finished`. All durations and positions are `@export`.

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
