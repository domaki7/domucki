# GDScript Style

## Naming Conventions

- **Files:** `snake_case` for everything (.gd, .tscn, .tres, directories)
- **Node names:** `PascalCase` in scene tree (HealthComponent, PlayerCamera)
- **class_name:** `PascalCase` matching the concept (HealthComponent, ItemData, PlayerIdleState)
- **Signals:** `snake_case`, past tense for events: `died`, `health_changed`, `item_added`
- **Signal handlers:** `_on_<emitter_node_name>_<signal_name>`
- **Variables/functions:** `snake_case`. Private with `_` prefix. Booleans use `is_`/`has_`/`can_` prefix.
- **Constants:** `SCREAMING_SNAKE_CASE`
- **Enums:** `PascalCase` name, `SCREAMING_SNAKE_CASE` values

## Code Example

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

## Script Section Order

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

## Type Annotations -- Always Explicit

```gdscript
var health: float = 100.0
var items: Array[ItemData] = []
var target: Node3D = null
func calculate(base: float, modifier: float) -> float:
```

## @export Grouping

```gdscript
@export_group("Movement")
@export var speed: float = 5.0
@export var jump_force: float = 8.0

@export_group("Combat")
@export var damage: float = 10.0
@export var attack_cooldown: float = 0.5

```

Component references are wired via `$NodeName` in `_ready()`, not `@export`.
