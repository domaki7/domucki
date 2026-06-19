class_name HurtboxComponent
extends Area3D

signal hurt(hitbox: HitboxComponent)

@export var health_component: HealthComponent

func _ready() -> void:
	monitoring = true
	monitorable = false
	area_entered.connect(_on_area_entered)
	if not health_component:
		_find_health_component()

func _find_health_component() -> void:
	var parent: Node = get_parent()
	if not parent:
		return
	for child: Node in parent.get_children():
		if child is HealthComponent:
			health_component = child as HealthComponent
			return

func _on_area_entered(area: Area3D) -> void:
	if area is HitboxComponent:
		var hitbox: HitboxComponent = area as HitboxComponent
		hurt.emit(hitbox)
		if health_component:
			health_component.take_damage(hitbox.damage)
