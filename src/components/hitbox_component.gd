class_name HitboxComponent
extends Area3D

signal hit(hurtbox: Area3D)

@export var damage: float = 10.0

@export_group("Swing Arc")
@export var swing_windup_offset: Vector3 = Vector3(0.0, 0.3, 0.3)
@export var swing_hit_offset: Vector3 = Vector3(-0.4, 0.0, -0.3)
@export var swing_windup_duration: float = 0.15
@export var swing_hit_duration: float = 0.2
@export var swing_recovery_duration: float = 0.25

var _collision_shape: CollisionShape3D
var _swing_tween: Tween
var _idle_position: Vector3

func _ready() -> void:
	monitoring = false
	monitorable = true
	_collision_shape = get_node("CollisionShape3D") as CollisionShape3D
	_idle_position = _collision_shape.position
	deactivate()

func activate() -> void:
	_collision_shape.disabled = false

func deactivate() -> void:
	_collision_shape.disabled = true

func play_swing_tween() -> void:
	_kill_swing_tween()
	var windup_pos: Vector3 = _idle_position + swing_windup_offset
	var hit_pos: Vector3 = _idle_position + swing_hit_offset
	_swing_tween = create_tween()
	_swing_tween.tween_property(_collision_shape, "position", windup_pos, swing_windup_duration)
	_swing_tween.tween_property(_collision_shape, "position", hit_pos, swing_hit_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_swing_tween.tween_property(_collision_shape, "position", _idle_position, swing_recovery_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)

func reset_position() -> void:
	_kill_swing_tween()
	_collision_shape.position = _idle_position

func update_idle_position(pos: Vector3) -> void:
	_idle_position = pos

func get_collision_shape() -> CollisionShape3D:
	return _collision_shape

func _kill_swing_tween() -> void:
	if _swing_tween and _swing_tween.is_valid():
		_swing_tween.kill()
	_swing_tween = null
