# Domucki

3D first-person action RPG built in Godot 4.7 with GDScript. Uses Jolt Physics, Forward Plus rendering, D3D12.

## Tooling

Use PowerShell for any file inspection tasks (reading 3D files, binary files, etc.). Never use Python.

@architecture.md
@style.md
@player.md
@patterns.md
@debug.md

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
  src/ui/               All UI (hud/, menus/, inventory/, dialog/, debug/)
  resources/            Custom Resource scripts and .tres data files
    items/              ItemData, WeaponData, etc. + definitions/ for .tres
    stats/              CharacterStats, StatModifier resources
    loot_tables/        LootTable resources
  levels/               Level/world scenes
  assets/               Raw assets only (models/, textures/, audio/, materials/, fonts/, shaders/)
  addons/               Third-party editor plugins and asset packs
    kaykit_character_pack_adventures/  KayKit Adventurers (CC0) -- characters, weapons, textures
```

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
