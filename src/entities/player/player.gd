class_name Player
extends CharacterBody3D

var state_machine: StateMachine
var movement_component: MovementComponent
var health_component: HealthComponent
var animation_component: AnimationComponent
var hitbox_component: HitboxComponent
var hurtbox_component: HurtboxComponent
var camera_arm: PlayerCameraArm
var _skeleton: Skeleton3D
var _upper_body_override: UpperBodyOverride

func _ready() -> void:
	state_machine = $StateMachine as StateMachine
	movement_component = $MovementComponent as MovementComponent
	health_component = $HealthComponent as HealthComponent
	animation_component = $AnimationComponent as AnimationComponent
	hitbox_component = $HitboxComponent as HitboxComponent
	hurtbox_component = $HurtboxComponent as HurtboxComponent
	camera_arm = $CameraArm as PlayerCameraArm
	_skeleton = $KnightModel/Rig/Skeleton3D as Skeleton3D

	GameManager.register_player(self)
	health_component.died.connect(_on_health_component_died)
	_setup_upper_body_override()
	_start_state_machine.call_deferred()
	_setup_equipment()

func _start_state_machine() -> void:
	state_machine.transition_to(&"IdleState")

func get_camera_basis() -> Basis:
	return camera_arm.global_basis

func start_defend() -> void:
	_upper_body_override.active = true

func stop_defend() -> void:
	_upper_body_override.active = false

func _on_health_component_died() -> void:
	state_machine.transition_to(&"DeathState")

func _setup_upper_body_override() -> void:
	var anim_player: AnimationPlayer = animation_component.animation_player
	var blocking_anim: Animation = anim_player.get_animation(&"Blocking")
	var sample_time: float = blocking_anim.length

	var lower_body_bones: Array[String] = [
		"root", "hips",
		"upperleg.l", "upperleg.r",
		"lowerleg.l", "lowerleg.r",
		"foot.l", "foot.r",
		"toes.l", "toes.r",
		"kneeIK.l", "kneeIK.r",
		"control-toe-roll.l", "control-toe-roll.r",
		"control-heel-roll.l", "control-heel-roll.r",
		"control-foot-roll.l", "control-foot-roll.r",
		"heelIK.l", "heelIK.r",
		"IK-foot.l", "IK-foot.r",
		"IK-toe.l", "IK-toe.r",
	]

	var bone_poses: Dictionary = {}
	for i: int in blocking_anim.get_track_count():
		var path: NodePath = blocking_anim.track_get_path(i)
		var path_str: String = str(path)
		var bone_name: String = path_str.get_slice(":", 1)

		var is_lower: bool = false
		for lb: String in lower_body_bones:
			if bone_name == lb:
				is_lower = true
				break
		if is_lower:
			continue

		var bone_idx: int = _skeleton.find_bone(bone_name)
		if bone_idx == -1:
			continue

		var track_type: int = blocking_anim.track_get_type(i)
		if not bone_poses.has(bone_idx):
			bone_poses[bone_idx] = {}

		if track_type == Animation.TYPE_ROTATION_3D:
			bone_poses[bone_idx]["rotation"] = blocking_anim.rotation_track_interpolate(i, sample_time)
		elif track_type == Animation.TYPE_POSITION_3D:
			bone_poses[bone_idx]["position"] = blocking_anim.position_track_interpolate(i, sample_time)

	_upper_body_override = UpperBodyOverride.new()
	_upper_body_override.bone_poses = bone_poses
	_upper_body_override.active = false
	_skeleton.add_child(_upper_body_override)

func _setup_equipment() -> void:
	var left_slot: BoneAttachment3D = _skeleton.get_node("handslot_l") as BoneAttachment3D
	var right_slot: BoneAttachment3D = _skeleton.get_node("handslot_r") as BoneAttachment3D

	(left_slot.get_node("1H_Sword_Offhand") as MeshInstance3D).visible = false

	(left_slot.get_node("Badge_Shield") as MeshInstance3D).visible = false
	(left_slot.get_node("Rectangle_Shield") as MeshInstance3D).visible = false
	(left_slot.get_node("Spike_Shield") as MeshInstance3D).visible = false

	(right_slot.get_node("2H_Sword") as MeshInstance3D).visible = false
