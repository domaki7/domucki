class_name Player
extends CharacterBody3D

var state_machine: StateMachine
var movement_component: MovementComponent
var health_component: HealthComponent
var animation_component: AnimationComponent
var camera_arm: PlayerCameraArm

func _ready() -> void:
	state_machine = $StateMachine as StateMachine
	movement_component = $MovementComponent as MovementComponent
	health_component = $HealthComponent as HealthComponent
	animation_component = $AnimationComponent as AnimationComponent
	camera_arm = $CameraArm as PlayerCameraArm

	GameManager.register_player(self)
	health_component.died.connect(_on_health_component_died)
	_start_state_machine.call_deferred()
	_setup_equipment()

func _start_state_machine() -> void:
	state_machine.transition_to(&"IdleState")

func get_camera_basis() -> Basis:
	return camera_arm.global_basis

func _on_health_component_died() -> void:
	pass

func _setup_equipment() -> void:
	var skeleton: Skeleton3D = $KnightModel/Rig/Skeleton3D
	var left_slot: BoneAttachment3D = skeleton.get_node("handslot_l") as BoneAttachment3D
	var right_slot: BoneAttachment3D = skeleton.get_node("handslot_r") as BoneAttachment3D

	# Hide offhand sword from left hand
	(left_slot.get_node("1H_Sword_Offhand") as MeshInstance3D).visible = false

	# Keep only Round_Shield, hide other shield variants
	(left_slot.get_node("Badge_Shield") as MeshInstance3D).visible = false
	(left_slot.get_node("Rectangle_Shield") as MeshInstance3D).visible = false
	(left_slot.get_node("Spike_Shield") as MeshInstance3D).visible = false

	# Keep only 1H_Sword, hide 2H variant
	(right_slot.get_node("2H_Sword") as MeshInstance3D).visible = false
