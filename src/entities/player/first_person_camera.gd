class_name FirstPersonCamera
extends Node3D

@export_group("Mouse")
@export var mouse_sensitivity: float = 0.002
@export var min_pitch: float = -80.0
@export var max_pitch: float = 80.0

var _yaw: float = 0.0
var _pitch: float = 0.0

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

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
