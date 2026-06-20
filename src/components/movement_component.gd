class_name MovementComponent
extends Node

signal movement_started
signal movement_stopped

@export_group("Movement")
@export var move_speed: float = 5.0
@export var acceleration: float = 10.0
@export var friction: float = 10.0
@export var rotation_speed: float = 10.0
@export var fps_mode: bool = false

@export_group("Gravity")
@export var gravity_multiplier: float = 1.0
@export var jump_force: float = 6.0

var body: CharacterBody3D
var _gravity: float = 0.0
var _was_moving: bool = false

func _ready() -> void:
	body = get_parent() as CharacterBody3D
	_gravity = ProjectSettings.get_setting("physics/3d/default_gravity", 9.8)

func apply_movement(direction: Vector3, delta: float) -> void:
	if direction.length() < 0.1:
		return

	var target_velocity_x: float = direction.x * move_speed
	var target_velocity_z: float = direction.z * move_speed

	body.velocity.x = lerpf(body.velocity.x, target_velocity_x, acceleration * delta)
	body.velocity.z = lerpf(body.velocity.z, target_velocity_z, acceleration * delta)

	if not fps_mode:
		var target_angle: float = atan2(-direction.x, -direction.z)
		body.rotation.y = lerp_angle(body.rotation.y, target_angle, rotation_speed * delta)

	_check_movement_signals()

func apply_jump_impulse() -> void:
	body.velocity.y = jump_force

func apply_gravity(delta: float) -> void:
	if not body.is_on_floor():
		body.velocity.y -= _gravity * gravity_multiplier * delta

func apply_friction(delta: float) -> void:
	body.velocity.x = lerpf(body.velocity.x, 0.0, friction * delta)
	body.velocity.z = lerpf(body.velocity.z, 0.0, friction * delta)
	if absf(body.velocity.x) < 0.1:
		body.velocity.x = 0.0
	if absf(body.velocity.z) < 0.1:
		body.velocity.z = 0.0
	_check_movement_signals()

func move() -> void:
	body.move_and_slide()

func is_moving() -> bool:
	var horizontal_velocity: Vector2 = Vector2(body.velocity.x, body.velocity.z)
	return horizontal_velocity.length() > 0.1

func _check_movement_signals() -> void:
	var moving_now: bool = is_moving()
	if moving_now and not _was_moving:
		movement_started.emit()
	elif not moving_now and _was_moving:
		movement_stopped.emit()
	_was_moving = moving_now
