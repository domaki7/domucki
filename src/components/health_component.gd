class_name HealthComponent
extends Node

signal health_changed(old_value: float, new_value: float)
signal damage_taken(amount: float)
signal healed(amount: float)
signal died

@export var max_health: float = 100.0
@export var is_invulnerable: bool = false

var current_health: float = 0.0
var is_dead: bool = false

func _ready() -> void:
	current_health = max_health

func take_damage(amount: float) -> void:
	if is_dead or is_invulnerable:
		return

	var old_health: float = current_health
	current_health = maxf(current_health - amount, 0.0)
	damage_taken.emit(amount)
	health_changed.emit(old_health, current_health)

	if current_health <= 0.0:
		is_dead = true
		died.emit()
		EventBus.entity_died.emit(owner)

func heal(amount: float) -> void:
	if is_dead:
		return

	var old_health: float = current_health
	current_health = minf(current_health + amount, max_health)
	healed.emit(amount)
	health_changed.emit(old_health, current_health)

func get_health_percent() -> float:
	return current_health / max_health
