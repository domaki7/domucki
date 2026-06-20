class_name ViewmodelComponent
extends Node3D

signal attack_finished
signal attack_hit_point
signal death_finished

@export_group("Sword Position")
@export var sword_idle_position: Vector3 = Vector3(0.6, -0.55, -0.9)
@export var sword_idle_rotation: Vector3 = Vector3(0.0, 80.5, -11.0)
@export var sword_mesh_scale: float = 0.6
@export var sword_pivot_scale: float = 1.0

@export_group("Shield Position")
@export var shield_idle_position: Vector3 = Vector3(-0.6, -0.35, -0.66)
@export var shield_idle_rotation: Vector3 = Vector3(-0.5, 180.0, 1.5)
@export var shield_mesh_scale: float = 0.6
@export var shield_pivot_scale: float = 1.0

@export_group("Bob")
@export var bob_frequency: float = 2.0
@export var bob_amplitude: float = 0.02

@export_group("Attack")
@export var attack_windup_duration: float = 0.15
@export var attack_swing_duration: float = 0.2
@export var attack_recovery_duration: float = 0.25
@export var attack_windup_rotation_offset: Vector3 = Vector3(40.0, 0.0, -20.0)
@export var attack_windup_position_offset: Vector3 = Vector3(0.0, 0.7, 0.35)
@export var attack_swing_rotation_offset: Vector3 = Vector3(0.0, -12.0, -60.0)
@export var attack_swing_position_offset: Vector3 = Vector3(-0.1, -0.3, -0.1)

@export_group("Block")
@export var shield_raise_duration: float = 0.15
@export var shield_raised_position: Vector3 = Vector3(-0.6, -0.35, -0.92)
@export var shield_raised_rotation: Vector3 = Vector3(0.0, 180.0, 10.0)

@export_group("Death")
@export var death_drop_duration: float = 0.6

var _sword_pivot: Node3D
var _shield_pivot: Node3D
var _sword_mesh: MeshInstance3D
var _shield_mesh: MeshInstance3D
var _current_tween: Tween
var _bob_time: float = 0.0
var _is_bobbing: bool = false
var _is_attacking: bool = false

func _ready() -> void:
	_sword_pivot = $SwordPivot as Node3D
	_shield_pivot = $ShieldPivot as Node3D

	_sword_pivot.position = sword_idle_position
	_sword_pivot.rotation_degrees = sword_idle_rotation
	_sword_pivot.scale = Vector3.ONE * sword_pivot_scale
	_shield_pivot.position = shield_idle_position
	_shield_pivot.rotation_degrees = shield_idle_rotation
	_shield_pivot.scale = Vector3.ONE * shield_pivot_scale

	_extract_meshes()

func _extract_meshes() -> void:
	var knight_scene: PackedScene = preload("res://addons/kaykit_character_pack_adventures/Characters/gltf/Knight.glb")
	var knight: Node3D = knight_scene.instantiate()

	var skeleton: Skeleton3D = knight.get_node("Rig/Skeleton3D") as Skeleton3D
	var sword_source: MeshInstance3D = skeleton.get_node("handslot_r/1H_Sword") as MeshInstance3D
	var shield_source: MeshInstance3D = skeleton.get_node("handslot_l/Round_Shield") as MeshInstance3D

	_sword_mesh = $SwordPivot/SwordMesh as MeshInstance3D
	_shield_mesh = $ShieldPivot/ShieldMesh as MeshInstance3D

	_sword_mesh.mesh = sword_source.mesh
	_shield_mesh.mesh = shield_source.mesh
	_sword_mesh.scale = Vector3.ONE * sword_mesh_scale
	_shield_mesh.scale = Vector3.ONE * shield_mesh_scale

	for i: int in sword_source.get_surface_override_material_count():
		var mat: Material = sword_source.get_surface_override_material(i)
		if mat:
			_sword_mesh.set_surface_override_material(i, mat)

	for i: int in shield_source.get_surface_override_material_count():
		var mat: Material = shield_source.get_surface_override_material(i)
		if mat:
			_shield_mesh.set_surface_override_material(i, mat)

	knight.queue_free()

func _process(delta: float) -> void:
	if _is_bobbing and not _is_attacking:
		_bob_time += delta * bob_frequency * TAU
		var bob_offset: float = sin(_bob_time) * bob_amplitude
		_sword_pivot.position.y = sword_idle_position.y + bob_offset
		_shield_pivot.position.y = shield_idle_position.y + bob_offset
	elif not _is_attacking:
		_bob_time = 0.0
		_sword_pivot.position.y = sword_idle_position.y
		_shield_pivot.position.y = shield_idle_position.y

func set_bobbing(active: bool) -> void:
	_is_bobbing = active
	if not active:
		_bob_time = 0.0

func play_attack() -> void:
	_kill_current_tween()
	_is_attacking = true

	var windup_rot: Vector3 = sword_idle_rotation + attack_windup_rotation_offset
	var swing_rot: Vector3 = sword_idle_rotation + attack_swing_rotation_offset
	var swing_pos: Vector3 = sword_idle_position + attack_swing_position_offset

	_current_tween = create_tween()
	_current_tween.tween_property(_sword_pivot, "rotation_degrees", windup_rot, attack_windup_duration)
	_current_tween.parallel().tween_property(_sword_pivot, "position", sword_idle_position + attack_windup_position_offset, attack_windup_duration)
	_current_tween.tween_callback(attack_hit_point.emit)
	_current_tween.tween_property(_sword_pivot, "rotation_degrees", swing_rot, attack_swing_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_current_tween.parallel().tween_property(_sword_pivot, "position", swing_pos, attack_swing_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_current_tween.tween_property(_sword_pivot, "rotation_degrees", sword_idle_rotation, attack_recovery_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	_current_tween.parallel().tween_property(_sword_pivot, "position", sword_idle_position, attack_recovery_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	_current_tween.tween_callback(_on_attack_tween_finished)

func play_attack_visual() -> void:
	_kill_current_tween()
	_is_attacking = true

	var windup_rot: Vector3 = sword_idle_rotation + attack_windup_rotation_offset
	var swing_rot: Vector3 = sword_idle_rotation + attack_swing_rotation_offset
	var swing_pos: Vector3 = sword_idle_position + attack_swing_position_offset

	_current_tween = create_tween()
	_current_tween.tween_property(_sword_pivot, "rotation_degrees", windup_rot, attack_windup_duration)
	_current_tween.parallel().tween_property(_sword_pivot, "position", sword_idle_position + attack_windup_position_offset, attack_windup_duration)
	_current_tween.tween_property(_sword_pivot, "rotation_degrees", swing_rot, attack_swing_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_current_tween.parallel().tween_property(_sword_pivot, "position", swing_pos, attack_swing_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_current_tween.tween_property(_sword_pivot, "rotation_degrees", sword_idle_rotation, attack_recovery_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	_current_tween.parallel().tween_property(_sword_pivot, "position", sword_idle_position, attack_recovery_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	_current_tween.tween_callback(_on_attack_tween_finished)

func _on_attack_tween_finished() -> void:
	_is_attacking = false
	attack_finished.emit()

func raise_shield() -> void:
	_kill_current_tween()
	_current_tween = create_tween()
	_current_tween.set_parallel(true)
	_current_tween.tween_property(_shield_pivot, "position", shield_raised_position, shield_raise_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_current_tween.tween_property(_shield_pivot, "rotation_degrees", shield_raised_rotation, shield_raise_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func lower_shield() -> void:
	_kill_current_tween()
	_current_tween = create_tween()
	_current_tween.set_parallel(true)
	_current_tween.tween_property(_shield_pivot, "position", shield_idle_position, shield_raise_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	_current_tween.tween_property(_shield_pivot, "rotation_degrees", shield_idle_rotation, shield_raise_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)

func play_death() -> void:
	_kill_current_tween()
	_is_attacking = true

	var drop_pos_sword: Vector3 = sword_idle_position + Vector3(0.2, -0.5, -0.2)
	var drop_rot_sword: Vector3 = sword_idle_rotation + Vector3(90.0, 0.0, 45.0)
	var drop_pos_shield: Vector3 = shield_idle_position + Vector3(-0.2, -0.5, -0.2)
	var drop_rot_shield: Vector3 = shield_idle_rotation + Vector3(-45.0, 0.0, -30.0)

	_current_tween = create_tween()
	_current_tween.set_parallel(true)
	_current_tween.tween_property(_sword_pivot, "position", drop_pos_sword, death_drop_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	_current_tween.tween_property(_sword_pivot, "rotation_degrees", drop_rot_sword, death_drop_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	_current_tween.tween_property(_shield_pivot, "position", drop_pos_shield, death_drop_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	_current_tween.tween_property(_shield_pivot, "rotation_degrees", drop_rot_shield, death_drop_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	_current_tween.chain().tween_callback(_on_death_tween_finished)

func _on_death_tween_finished() -> void:
	_is_attacking = false
	death_finished.emit()

func _kill_current_tween() -> void:
	if _current_tween and _current_tween.is_valid():
		_current_tween.kill()
	_current_tween = null
