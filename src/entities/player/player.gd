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

func _start_state_machine() -> void:
	state_machine.transition_to(&"IdleState")

func get_camera_basis() -> Basis:
	return camera_arm.global_basis

func _on_health_component_died() -> void:
	pass
