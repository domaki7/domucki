class_name FirstPersonCamera
extends Node3D

@export_group("Mouse")
@export var mouse_sensitivity: float = 0.002
@export var min_pitch: float = -80.0
@export var max_pitch: float = 80.0

@export_group("Sprint FOV")
@export var sprint_fov_increase: float = 10.0
@export var fov_tween_duration: float = 0.25

var _yaw: float = 0.0
var _pitch: float = 0.0
var _camera: Camera3D = null
var _base_fov: float = 75.0
var _fov_tween: Tween = null

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_camera = $Camera3D as Camera3D
	_base_fov = _camera.fov

func _unhandled_input(event: InputEvent) -> void:
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	if event is InputEventMouseMotion:
		var mouse_event: InputEventMouseMotion = event as InputEventMouseMotion
		_yaw -= mouse_event.relative.x * mouse_sensitivity
		_pitch -= mouse_event.relative.y * mouse_sensitivity
		_pitch = clampf(_pitch, deg_to_rad(min_pitch), deg_to_rad(max_pitch))

func _physics_process(_delta: float) -> void:
	var body: Node3D = get_parent() as Node3D
	if body:
		body.rotation.y = _yaw
	rotation.x = _pitch

func set_sprint_fov(active: bool) -> void:
	if _fov_tween and _fov_tween.is_running():
		_fov_tween.kill()
	var target_fov: float = _base_fov + sprint_fov_increase if active else _base_fov
	_fov_tween = create_tween()
	_fov_tween.tween_property(_camera, "fov", target_fov, fov_tween_duration)
