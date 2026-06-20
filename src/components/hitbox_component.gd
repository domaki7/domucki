class_name HitboxComponent
extends Area3D

signal hit(hurtbox: Area3D)

@export var damage: float = 10.0

var _collision_shape: CollisionShape3D

func _ready() -> void:
	monitoring = false
	monitorable = true
	_collision_shape = get_node("CollisionShape3D") as CollisionShape3D
	deactivate()

func activate() -> void:
	_collision_shape.disabled = false

func deactivate() -> void:
	_collision_shape.disabled = true

func get_collision_shape() -> CollisionShape3D:
	return _collision_shape
