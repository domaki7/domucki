class_name HurtboxComponent
extends Area3D

signal hurt(hitbox: HitboxComponent)
signal damage_blocked(hitbox: HitboxComponent)

@export var health_component: HealthComponent

var is_blocking: bool = false
var _stamina_component: StaminaComponent = null

func _ready() -> void:
	monitoring = true
	monitorable = false
	area_entered.connect(_on_area_entered)
	if not health_component:
		_find_health_component()
	_find_stamina_component()

func _find_health_component() -> void:
	var parent: Node = get_parent()
	if not parent:
		return
	for child: Node in parent.get_children():
		if child is HealthComponent:
			health_component = child as HealthComponent
			return

func _find_stamina_component() -> void:
	var parent: Node = get_parent()
	if not parent:
		return
	for child: Node in parent.get_children():
		if child is StaminaComponent:
			_stamina_component = child as StaminaComponent
			return

func _on_area_entered(area: Area3D) -> void:
	if area is HitboxComponent:
		var hitbox: HitboxComponent = area as HitboxComponent
		if is_blocking and _stamina_component and _stamina_component.can_spend(_stamina_component.block_cost):
			_stamina_component.spend(_stamina_component.block_cost)
			damage_blocked.emit(hitbox)
			return
		hurt.emit(hitbox)
		if health_component:
			health_component.take_damage(hitbox.damage)
