class_name Player
extends CharacterBody3D

var state_machine: StateMachine
var movement_component: MovementComponent
var health_component: HealthComponent
var animation_component: AnimationComponent
var hitbox_component: HitboxComponent
var hurtbox_component: HurtboxComponent
var viewmodel_component: ViewmodelComponent
var camera_arm: FirstPersonCamera

func _ready() -> void:
	state_machine = $StateMachine as StateMachine
	movement_component = $MovementComponent as MovementComponent
	health_component = $HealthComponent as HealthComponent
	animation_component = $AnimationComponent as AnimationComponent
	hitbox_component = $HitboxComponent as HitboxComponent
	hurtbox_component = $HurtboxComponent as HurtboxComponent
	camera_arm = $FirstPersonCamera as FirstPersonCamera
	viewmodel_component = $FirstPersonCamera/Camera3D/ViewmodelComponent as ViewmodelComponent

	$KnightModel.visible = false

	GameManager.register_player(self)
	health_component.died.connect(_on_health_component_died)
	_start_state_machine.call_deferred()

func _start_state_machine() -> void:
	state_machine.transition_to(&"IdleState")

func get_camera_basis() -> Basis:
	return camera_arm.global_basis

func _on_health_component_died() -> void:
	state_machine.transition_to(&"DeathState")
