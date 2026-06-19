class_name Barbarian
extends CharacterBody3D

var state_machine: StateMachine
var movement_component: MovementComponent
var health_component: HealthComponent
var animation_component: AnimationComponent
var hitbox_component: HitboxComponent
var hurtbox_component: HurtboxComponent
var _skeleton: Skeleton3D

func _ready() -> void:
	state_machine = $StateMachine as StateMachine
	movement_component = $MovementComponent as MovementComponent
	health_component = $HealthComponent as HealthComponent
	animation_component = $AnimationComponent as AnimationComponent
	hitbox_component = $HitboxComponent as HitboxComponent
	hurtbox_component = $HurtboxComponent as HurtboxComponent
	_skeleton = $BarbarianModel/Rig/Skeleton3D as Skeleton3D

	health_component.died.connect(_on_health_component_died)
	_setup_equipment()
	_start_state_machine.call_deferred()

func _start_state_machine() -> void:
	state_machine.transition_to(&"IdleState")

func _on_health_component_died() -> void:
	state_machine.transition_to(&"DeathState")

func _setup_equipment() -> void:
	var left_slot: BoneAttachment3D = _skeleton.get_node("handslot_l") as BoneAttachment3D
	var right_slot: BoneAttachment3D = _skeleton.get_node("handslot_r") as BoneAttachment3D
	var head_slot: BoneAttachment3D = _skeleton.get_node("head") as BoneAttachment3D
	var chest_slot: BoneAttachment3D = _skeleton.get_node("chest") as BoneAttachment3D

	(left_slot.get_node("1H_Axe_Offhand") as MeshInstance3D).visible = false
	(left_slot.get_node("Barbarian_Round_Shield") as MeshInstance3D).visible = false

	(right_slot.get_node("2H_Axe") as MeshInstance3D).visible = false
	(right_slot.get_node("Mug") as MeshInstance3D).visible = false

	(head_slot.get_node("Barbarian_Hat") as MeshInstance3D).visible = false
	(chest_slot.get_node("Barbarian_Cape") as MeshInstance3D).visible = false
