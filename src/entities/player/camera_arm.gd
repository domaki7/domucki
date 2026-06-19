class_name PlayerCameraArm
extends Node3D

@export_group("Follow")
@export var follow_speed: float = 8.0

@export_group("Orbit")
@export var mouse_sensitivity: float = 0.002
@export var min_pitch: float = -60.0
@export var max_pitch: float = 30.0

var _target: Node3D
var _spring_arm: SpringArm3D
var _yaw: float = 0.0
var _pitch: float = -0.35

func _ready() -> void:
	_target = get_parent() as Node3D
	_spring_arm = $SpringArm3D as SpringArm3D
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	top_level = true
	if _target:
		global_position = _target.global_position

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mouse_event: InputEventMouseMotion = event as InputEventMouseMotion
		_yaw -= mouse_event.relative.x * mouse_sensitivity
		_pitch -= mouse_event.relative.y * mouse_sensitivity
		_pitch = clampf(_pitch, deg_to_rad(min_pitch), deg_to_rad(max_pitch))

func _physics_process(delta: float) -> void:
	if not _target:
		return
	global_position = global_position.lerp(_target.global_position, follow_speed * delta)
	rotation = Vector3(_pitch, _yaw, 0.0)
