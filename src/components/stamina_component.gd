class_name StaminaComponent
extends Node

signal stamina_changed(old_value: float, new_value: float)
signal stamina_depleted

@export_group("Stamina")
@export var max_stamina: float = 100.0
@export var regen_rate: float = 15.0
@export var regen_delay: float = 0.5

@export_group("Costs")
@export var sprint_drain_rate: float = 20.0
@export var jump_cost: float = 15.0
@export var attack_cost: float = 20.0
@export var block_cost: float = 25.0

var current_stamina: float = 0.0
var is_sprinting: bool = false
var _regen_timer: float = 0.0

func _ready() -> void:
	current_stamina = max_stamina

func _physics_process(delta: float) -> void:
	if is_sprinting:
		_drain(sprint_drain_rate * delta)
	elif _regen_timer > 0.0:
		_regen_timer -= delta
	elif current_stamina < max_stamina:
		_regenerate(regen_rate * delta)

func spend(amount: float) -> bool:
	var had_enough: bool = current_stamina >= amount
	var old_stamina: float = current_stamina
	current_stamina = maxf(current_stamina - amount, 0.0)
	_regen_timer = regen_delay
	if current_stamina != old_stamina:
		stamina_changed.emit(old_stamina, current_stamina)
		if current_stamina <= 0.0:
			stamina_depleted.emit()
	return had_enough

func can_spend(amount: float) -> bool:
	return current_stamina >= amount

func get_stamina_percent() -> float:
	if max_stamina <= 0.0:
		return 0.0
	return current_stamina / max_stamina

func _drain(amount: float) -> void:
	if current_stamina <= 0.0:
		return
	var old_stamina: float = current_stamina
	current_stamina = maxf(current_stamina - amount, 0.0)
	if current_stamina != old_stamina:
		stamina_changed.emit(old_stamina, current_stamina)
		if current_stamina <= 0.0:
			stamina_depleted.emit()

func _regenerate(amount: float) -> void:
	var old_stamina: float = current_stamina
	current_stamina = minf(current_stamina + amount, max_stamina)
	if current_stamina != old_stamina:
		stamina_changed.emit(old_stamina, current_stamina)
