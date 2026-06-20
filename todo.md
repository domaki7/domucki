# Todo

## Gameplay / Combat

- [ ] [HIGH] Dodge/roll mechanic
  - [ ] Create DodgeState with i-frames
  - [ ] Add stamina cost for dodge
  - [ ] Add viewmodel dodge animation (tween-based)
  - [ ] Add input action mapping (e.g. double-tap direction or dedicated key)
- [ ] [HIGH] Attack combo system
  - [ ] Track combo counter in AttackState
  - [ ] Chain attacks with timing window between swings
  - [ ] Scale damage per combo hit
  - [ ] Add distinct viewmodel swing directions per combo step
- [ ] [HIGH] Knockback/stagger system
  - [ ] Create StaggerState for player and enemies
  - [ ] Apply knockback velocity on hit
  - [ ] Add hitstun duration (brief state lock on taking damage)
  - [ ] Interrupt enemy attacks on stagger
- [ ] [MED] Charged/heavy attack
  - [ ] Create ChargedAttackState (hold attack button to charge)
  - [ ] Higher damage + stamina cost for charged hits
  - [ ] Distinct viewmodel windup animation for charged attack
  - [ ] Visual/audio cue when fully charged
- [ ] [MED] Damage types system
  - [ ] Create DamageInfo resource (type: slash/blunt/pierce, amount, source)
  - [ ] Replace flat damage float with DamageInfo throughout hitbox/hurtbox flow
  - [ ] Add armor/resistance values to HealthComponent or new ArmorComponent
- [ ] [MED] Damage variation
  - [ ] Add random damage range (±10% of base)
  - [ ] Add critical hit chance and multiplier
  - [ ] Add weak point detection (headshot/back hit)
- [ ] [LOW] Status effects
  - [ ] Create StatusEffectComponent (manages active effects with tick timers)
  - [ ] Implement poison (damage over time)
  - [ ] Implement bleed (damage over time, stacks)
  - [ ] Implement burn (area damage over time)
  - [ ] Add visual indicators for active effects (HUD icons, screen tint)
- [ ] [LOW] Parry mechanic
  - [ ] Add timed block window at start of DefendState
  - [ ] Reward successful parry (stamina refund, riposte opportunity)
  - [ ] Add parry feedback (sound, flash, brief slow-mo)

## Enemies / AI

- [ ] [HIGH] New enemy type: Mage
  - [ ] Create Mage entity with KayKit Mage model
  - [ ] Add ProjectileComponent for ranged attacks
  - [ ] Implement kiting AI (maintain distance, retreat when player closes in)
  - [ ] Add spellcast animation + projectile spawn
- [ ] [HIGH] Patrol state for enemies
  - [ ] Create PatrolState with waypoint system
  - [ ] Add idle-walk cycle between patrol points
  - [ ] Transition to chase on player detection
  - [ ] Support area patrol (random points within radius)
- [ ] [MED] New enemy type: Rogue
  - [ ] Create Rogue entity with KayKit Rogue model
  - [ ] Fast movement speed, dual-wield attacks
  - [ ] Add dodge/sidestep behavior to avoid player attacks
  - [ ] Flanking AI (circle around to attack from behind)
- [ ] [MED] Enemy attack cooldowns
  - [ ] Add cooldown timer between attacks (prevent spam)
  - [ ] Variable cooldown per enemy type
  - [ ] Brief idle/circle behavior during cooldown
- [ ] [MED] Line-of-sight detection
  - [ ] Add raycast check before transitioning to chase
  - [ ] Add hearing range (shorter range, no LOS required)
  - [ ] Add alert state (investigate last known position)
- [ ] [LOW] Boss enemy
  - [ ] Design multi-phase boss with unique mechanics
  - [ ] Create dedicated boss arena
  - [ ] Add phase transitions with health thresholds
  - [ ] Add boss health bar UI
- [ ] [LOW] Group AI coordination
  - [ ] Circling behavior (enemies spread around player)
  - [ ] Attack turn system (one attacks while others wait)
  - [ ] Coordinated flanking positions

## UI / HUD / Menus

- [ ] [HIGH] Enemy health bars
  - [ ] Create floating health bar above enemies (world-space UI)
  - [ ] Show on damage, hide after delay
  - [ ] Reuse HealthBar component with enemy styling
- [ ] [HIGH] Damage numbers
  - [ ] Create floating damage text on hit
  - [ ] Color-code by damage type (white normal, yellow crit, red bleed)
  - [ ] Animate upward drift + fade out
- [ ] [MED] Pause menu
  - [ ] Create pause screen with resume, settings, quit options
  - [ ] Integrate with GameManager.PAUSED state
  - [ ] Add Escape key input action
- [ ] [MED] Main menu
  - [ ] Create title screen with new game, load, settings, quit
  - [ ] Add as initial scene in project settings
  - [ ] Wire to SceneManager for level transitions
- [ ] [MED] Interaction prompts
  - [ ] Create world-space "Press E" prompt
  - [ ] Context-sensitive labels (open, talk, pick up)
  - [ ] Show/hide based on proximity + raycast
- [ ] [LOW] Settings menu
  - [ ] Audio volume sliders (master, music, SFX)
  - [ ] Mouse sensitivity slider
  - [ ] Graphics quality presets
- [ ] [LOW] Game over screen
  - [ ] Create death screen before level reload
  - [ ] Show "You Died" with retry/quit options
  - [ ] Replace direct scene reload in DeathState

## World / Levels / Art

- [ ] [HIGH] Second combat arena
  - [ ] Design arena with varied geometry (walls, pillars, ramps)
  - [ ] Add cover positions and elevation changes
  - [ ] Place mixed enemy encounters
- [ ] [MED] Interactable objects
  - [ ] Create InteractableComponent (Area3D on layer 9)
  - [ ] Implement doors (open/close)
  - [ ] Implement chests (open, spawn loot)
  - [ ] Implement levers (trigger connected events)
- [ ] [MED] Environmental hazards
  - [ ] Spike traps (damage on contact)
  - [ ] Fire areas (burn status effect)
  - [ ] Fall pits (instant death or high damage)
- [ ] [LOW] NPC system
  - [ ] Create NPC entity template with dialogue triggers
  - [ ] Implement basic dialogue UI (text box, choices)
  - [ ] Add quest giver functionality
- [ ] [LOW] Level transitions
  - [ ] Create transition zones (doors/portals between areas)
  - [ ] Wire to SceneManager async loading
  - [ ] Add loading screen

## Systems / Infrastructure

- [ ] [HIGH] Audio integration
  - [ ] Add attack swing SFX (play on attack_hit_point)
  - [ ] Add hit impact SFX (play on hurtbox hurt signal)
  - [ ] Add footstep SFX (play in RunState/SprintState)
  - [ ] Add ambient music to test arena
- [ ] [MED] Loot/item drops
  - [ ] Create ItemData resource script
  - [ ] Create item drop scenes (spawn on enemy death)
  - [ ] Add pickup mechanic (player walks over or presses interact)
  - [ ] Create LootTable resource for per-enemy drop rates
- [ ] [MED] Equipment system
  - [ ] Create WeaponData resource (damage, type, speed, model)
  - [ ] Add weapon switching (swap viewmodel mesh + stats)
  - [ ] Apply stat modifiers from equipped items
- [ ] [LOW] Save/load integration
  - [ ] Add player to "saveable" group with save_data/load_data
  - [ ] Add save/load triggers in pause menu
  - [ ] Implement auto-save on level transitions
- [ ] [LOW] Stats/progression
  - [ ] Create character stat scaling system
  - [ ] Add XP gain on enemy kills
  - [ ] Add level-up with stat point allocation

## Polish / Quality of Life

- [ ] [MED] Hit feedback
  - [ ] Add screen shake on taking damage
  - [ ] Add brief white flash on hit
  - [ ] Add hit freeze frame (brief time scale dip on heavy hits)
- [ ] [MED] Death/respawn improvements
  - [ ] Add death screen with retry option
  - [ ] Add checkpoint system for respawn points
  - [ ] Smooth transition instead of hard scene reload
- [ ] [LOW] Footstep sounds
  - [ ] Surface-aware footstep SFX (stone, grass, wood)
  - [ ] Tie to RunState/SprintState movement
  - [ ] Vary playback rate with movement speed
- [ ] [LOW] Particle effects
  - [ ] Weapon trail effect during attack swings
  - [ ] Sparks/blood on hit impact
  - [ ] Dust puff on landing from jump
